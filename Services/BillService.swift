import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class BillService: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    @Published var bills: [Bill] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Fetch bills for a specific property
    func fetchBills(for propertyId: String) {
        isLoading = true
        error = nil
        
        db.collection("bills")
            .whereField("propertyId", isEqualTo: propertyId)
            .order(by: "dueDate")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = "Failed to fetch bills: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.bills = []
                    return
                }
                
                self.bills = documents.compactMap { document in
                    try? document.data(as: Bill.self)
                }
                
                // Check for overdue bills and update status
                let currentDate = Date()
                for (index, bill) in self.bills.enumerated() {
                    if bill.status == .due && bill.dueDate.dateValue() < currentDate {
                        // Update to overdue
                        var updatedBill = bill
                        updatedBill.status = .overdue
                        self.bills[index] = updatedBill
                        
                        // Also update in Firestore
                        if let billId = bill.id {
                            self.db.collection("bills").document(billId).updateData([
                                "status": "overdue"
                            ])
                        }
                    }
                }
            }
    }
    
    // Add a new bill
    func addBill(bill: Bill, pdfData: Data? = nil, completion: @escaping (Result<Bill, Error>) -> Void) {
        isLoading = true
        error = nil
        
        // If we have PDF data, upload it first
        if let pdfData = pdfData {
            let billId = UUID().uuidString
            let pdfRef = storage.child("bills/\(billId).pdf")
            
            pdfRef.putData(pdfData, metadata: nil) { [weak self] metadata, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.error = "Failed to upload PDF: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }
                
                // Get the download URL
                pdfRef.downloadURL { [weak self] url, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.isLoading = false
                        self.error = "Failed to get PDF URL: \(error.localizedDescription)"
                        completion(.failure(error))
                        return
                    }
                    
                    guard let downloadURL = url else {
                        self.isLoading = false
                        self.error = "Missing PDF download URL"
                        completion(.failure(NSError(domain: "BillService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing download URL"])))
                        return
                    }
                    
                    // Create the bill with the PDF URL
                    var billWithPDF = bill
                    billWithPDF.pdfUrl = downloadURL.absoluteString
                    
                    self.saveBill(billWithPDF, completion: completion)
                }
            }
        } else {
            // No PDF to upload, just save the bill
            saveBill(bill, completion: completion)
        }
    }
    
    // Helper method to save a bill to Firestore
    private func saveBill(_ bill: Bill, completion: @escaping (Result<Bill, Error>) -> Void) {
        do {
            let ref = db.collection("bills").document()
            var newBill = bill
            newBill.id = ref.documentID
            newBill.createdAt = Timestamp(date: Date())
            
            try ref.setData(from: newBill)
            
            // Add to local list
            self.bills.append(newBill)
            
            self.isLoading = false
            completion(.success(newBill))
        } catch {
            self.isLoading = false
            self.error = "Failed to save bill: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }
    
    // Mark a bill as paid
    func markBillAsPaid(billId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("bills").document(billId).updateData([
            "status": "paid",
            "updatedAt": Timestamp(date: Date())
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Failed to mark bill as paid: \(error.localizedDescription)"
                completion(.failure(error))
                return
            }
            
            // Update the local list
            if let index = self.bills.firstIndex(where: { $0.id == billId }) {
                var updatedBill = self.bills[index]
                updatedBill.status = .paid
                updatedBill.updatedAt = Timestamp(date: Date())
                self.bills[index] = updatedBill
            }
            
            completion(.success(()))
        }
    }
    
    // Delete a bill
    func deleteBill(billId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // If the bill has a PDF, delete it from storage first
        if let bill = bills.first(where: { $0.id == billId }),
           let pdfUrlString = bill.pdfUrl,
           let pdfUrl = URL(string: pdfUrlString),
           let path = pdfUrl.path.components(separatedBy: "bills/").last {
            
            let pdfRef = storage.child("bills/\(path)")
            pdfRef.delete { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = "Failed to delete PDF: \(error.localizedDescription)"
                    // Continue to delete the bill record even if PDF deletion fails
                }
                
                self.deleteBillDocument(billId: billId, completion: completion)
            }
        } else {
            // No PDF or couldn't parse the URL, just delete the bill document
            deleteBillDocument(billId: billId, completion: completion)
        }
    }
    
    // Helper to delete the bill document from Firestore
    private func deleteBillDocument(billId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("bills").document(billId).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Failed to delete bill: \(error.localizedDescription)"
                completion(.failure(error))
                return
            }
            
            // Remove from local list
            self.bills.removeAll { $0.id == billId }
            
            completion(.success(()))
        }
    }
} 