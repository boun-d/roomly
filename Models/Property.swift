import Foundation
import UIKit

struct Property: Identifiable, Codable {
    let id: String
    let address: String
    let rent: Int
    let bedrooms: Int
    let bathrooms: Int
    let squareFeet: Int
    let tenants: [String] // User IDs
    let maintenanceCount: Int
    
    // UIImage is not Codable, so we'll handle it separately
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id, address, rent, bedrooms, bathrooms, squareFeet, tenants, maintenanceCount
    }
}

// Extension to make Property conform to Hashable for using in ForEach
extension Property: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Property, rhs: Property) -> Bool {
        return lhs.id == rhs.id
    }
} 