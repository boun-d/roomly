import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

enum MaintenanceStatus: String, Codable {
    case scheduled
    case completed
    case cancelled
    
    var color: String {
        switch self {
        case .scheduled:
            return "#4A90E2" // Soft Blue
        case .completed:
            return "#34C759" // Green
        case .cancelled:
            return "#FF3B30" // Red
        }
    }
}

struct Maintenance: Identifiable, Codable {
    @DocumentID var id: String?
    var propertyId: String
    var description: String
    var date: Timestamp // Scheduled date and time
    var status: MaintenanceStatus
    var notes: String?
    
    // Additional properties
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var createdBy: String? // User ID who created this maintenance event
    
    // Helper to format the maintenance date
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date.dateValue())
    }
    
    // Helper to check if maintenance is upcoming (within 2 days)
    func isUpcoming() -> Bool {
        let currentDate = Date()
        let twoDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: currentDate) ?? currentDate
        return date.dateValue() <= twoDaysFromNow && date.dateValue() > currentDate
    }
    
    // Helper to check if maintenance is today
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date.dateValue())
    }
} 