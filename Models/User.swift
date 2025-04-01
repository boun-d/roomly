import Foundation
import FirebaseFirestoreSwift

enum UserRole: String, Codable {
    case tenant
    case landlord
}

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let propertyIds: [String]
    let createdAt: String
    
    var isTenant: Bool {
        return role == .tenant
    }
    
    var isLandlord: Bool {
        return role == .landlord
    }
}

// Extension to make User conform to Hashable for using in ForEach
extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
} 