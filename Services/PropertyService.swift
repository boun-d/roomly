import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class PropertyService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var properties: [Property] = []
    @Published var selectedProperty: Property?
    @Published var isLoading = false
    @Published var error: String?
    
    // Fetch properties for a specific user
    func fetchProperties(for userId: String, role: UserRole) {
        isLoading = true
        error = nil
        
        let query: Query
        
        if role == .landlord {
            // Landlords see properties they own
            query = db.collection("properties").whereField("landlordId", isEqualTo: userId)
        } else {
            // Tenants see properties they're assigned to
            query = db.collection("properties").whereField("tenantIds", arrayContains: userId)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.error = "Failed to fetch properties: \(error.localizedDescription)"
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.properties = []
                return
            }
            
            self.properties = documents.compactMap { document in
                try? document.data(as: Property.self)
            }
            
            // If there's only one property, select it automatically
            if self.properties.count == 1 {
                self.selectedProperty = self.properties.first
            }
        }
    }
    
    // Add a property (for landlords)
    func addProperty(property: Property, completion: @escaping (Result<Property, Error>) -> Void) {
        do {
            let ref = db.collection("properties").document()
            var newProperty = property
            newProperty.id = ref.documentID
            
            try ref.setData(from: newProperty)
            
            // Add the property to the local list
            self.properties.append(newProperty)
            
            completion(.success(newProperty))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Update a property
    func updateProperty(property: Property, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let propertyId = property.id else {
            completion(.failure(NSError(domain: "PropertyService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Property ID is missing"])))
            return
        }
        
        do {
            try db.collection("properties").document(propertyId).setData(from: property)
            
            // Update property in the local list
            if let index = properties.firstIndex(where: { $0.id == propertyId }) {
                properties[index] = property
            }
            
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Add a tenant to a property
    func addTenant(email: String, to propertyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // First, find the user by email
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(.failure(NSError(domain: "PropertyService", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            guard let tenant = try? document.data(as: User.self),
                  let tenantId = tenant.id else {
                completion(.failure(NSError(domain: "PropertyService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                return
            }
            
            // Now add this tenant to the property
            self.db.collection("properties").document(propertyId).updateData([
                "tenantIds": FieldValue.arrayUnion([tenantId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Update tenant's propertyIds
                    self.db.collection("users").document(tenantId).updateData([
                        "propertyIds": FieldValue.arrayUnion([propertyId])
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            // Also update local state if necessary
                            if let propertyIndex = self.properties.firstIndex(where: { $0.id == propertyId }),
                               var property = self.properties[propertyIndex].id != nil ? self.properties[propertyIndex] : nil {
                                property.tenantIds.append(tenantId)
                                self.properties[propertyIndex] = property
                            }
                            
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    // Get a single property by ID
    func getProperty(id: String, completion: @escaping (Result<Property, Error>) -> Void) {
        db.collection("properties").document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "PropertyService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Property not found"])))
                return
            }
            
            do {
                let property = try snapshot.data(as: Property.self)
                completion(.success(property))
            } catch {
                completion(.failure(error))
            }
        }
    }
} 