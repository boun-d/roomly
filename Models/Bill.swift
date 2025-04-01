import Foundation

struct Bill: Identifiable, Codable {
    let id: String
    let title: String
    let amount: Int
    let dueDate: String
    let isPaid: Bool
    let propertyId: String
    let tenantId: String
}

// Extension to make Bill conform to Hashable for using in ForEach
extension Bill: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Bill, rhs: Bill) -> Bool {
        return lhs.id == rhs.id
    }
} 