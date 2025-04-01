import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MaintenanceService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var maintenanceEvents: [Maintenance] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Fetch maintenance events for a specific property
    func fetchMaintenanceEvents(for propertyId: String) {
        isLoading = true
        error = nil
        
        db.collection("maintenance")
            .whereField("propertyId", isEqualTo: propertyId)
            .order(by: "date")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = "Failed to fetch maintenance events: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.maintenanceEvents = []
                    return
                }
                
                self.maintenanceEvents = documents.compactMap { document in
                    try? document.data(as: Maintenance.self)
                }
                
                // Check for past events and update status if necessary
                let currentDate = Date()
                for (index, event) in self.maintenanceEvents.enumerated() {
                    if event.status == .scheduled && event.date.dateValue() < currentDate {
                        // Only automatically mark as completed if it's in the past
                        var updatedEvent = event
                        updatedEvent.status = .completed
                        self.maintenanceEvents[index] = updatedEvent
                        
                        // Also update in Firestore
                        if let eventId = event.id {
                            self.db.collection("maintenance").document(eventId).updateData([
                                "status": "completed"
                            ])
                        }
                    }
                }
            }
    }
    
    // Add a new maintenance event
    func addMaintenanceEvent(event: Maintenance, completion: @escaping (Result<Maintenance, Error>) -> Void) {
        do {
            let ref = db.collection("maintenance").document()
            var newEvent = event
            newEvent.id = ref.documentID
            newEvent.createdAt = Timestamp(date: Date())
            
            try ref.setData(from: newEvent)
            
            // Add to local list
            self.maintenanceEvents.append(newEvent)
            
            completion(.success(newEvent))
        } catch {
            self.error = "Failed to save maintenance event: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }
    
    // Update a maintenance event
    func updateMaintenanceEvent(event: Maintenance, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let eventId = event.id else {
            completion(.failure(NSError(domain: "MaintenanceService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Maintenance event ID is missing"])))
            return
        }
        
        do {
            var updatedEvent = event
            updatedEvent.updatedAt = Timestamp(date: Date())
            
            try db.collection("maintenance").document(eventId).setData(from: updatedEvent)
            
            // Update in local list
            if let index = maintenanceEvents.firstIndex(where: { $0.id == eventId }) {
                maintenanceEvents[index] = updatedEvent
            }
            
            completion(.success(()))
        } catch {
            self.error = "Failed to update maintenance event: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }
    
    // Change the status of a maintenance event
    func changeMaintenanceStatus(eventId: String, newStatus: MaintenanceStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("maintenance").document(eventId).updateData([
            "status": newStatus.rawValue,
            "updatedAt": Timestamp(date: Date())
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Failed to update maintenance status: \(error.localizedDescription)"
                completion(.failure(error))
                return
            }
            
            // Update in local list
            if let index = self.maintenanceEvents.firstIndex(where: { $0.id == eventId }) {
                var updatedEvent = self.maintenanceEvents[index]
                updatedEvent.status = newStatus
                updatedEvent.updatedAt = Timestamp(date: Date())
                self.maintenanceEvents[index] = updatedEvent
            }
            
            completion(.success(()))
        }
    }
    
    // Delete a maintenance event
    func deleteMaintenanceEvent(eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("maintenance").document(eventId).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Failed to delete maintenance event: \(error.localizedDescription)"
                completion(.failure(error))
                return
            }
            
            // Remove from local list
            self.maintenanceEvents.removeAll { $0.id == eventId }
            
            completion(.success(()))
        }
    }
    
    // Get upcoming maintenance events (within the next 7 days)
    func getUpcomingMaintenanceEvents(for propertyId: String, completion: @escaping ([Maintenance]) -> Void) {
        let currentDate = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: currentDate) ?? currentDate
        
        db.collection("maintenance")
            .whereField("propertyId", isEqualTo: propertyId)
            .whereField("status", isEqualTo: MaintenanceStatus.scheduled.rawValue)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: currentDate))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: sevenDaysLater))
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching upcoming maintenance: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let upcomingEvents = documents.compactMap { document in
                    try? document.data(as: Maintenance.self)
                }
                
                completion(upcomingEvents)
            }
    }
} 