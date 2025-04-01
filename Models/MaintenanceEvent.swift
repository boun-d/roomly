import Foundation

enum MaintenanceStatus: String, Codable {
    case pending
    case inProgress
    case completed
}

struct MaintenanceEvent: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let status: MaintenanceStatus
    let propertyId: String
    let createdAt: String
    let completedAt: String?
}

// Extension to make MaintenanceEvent conform to Hashable for using in ForEach
extension MaintenanceEvent: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MaintenanceEvent, rhs: MaintenanceEvent) -> Bool {
        return lhs.id == rhs.id
    }
} 