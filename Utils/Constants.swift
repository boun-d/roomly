import SwiftUI

// App-wide constants
struct Constants {
    // App name
    static let appName = "Roomie with a View"
    
    // Colors (based on the specifications)
    struct Colors {
        static let primaryBlue = Color(hex: "#0080FF")
        static let secondaryBlue = Color(hex: "#74B3FF")
        static let lightGray = Color(hex: "#F5F7FA")
        static let darkText = Color(hex: "#1F2937")
        static let grayText = Color(hex: "#6B7280")
        static let success = Color(hex: "#34C759")
        static let warning = Color(hex: "#FFB800")
        static let error = Color(hex: "#FF3B30")
        static let white = Color.white                  // White for cards
    }
    
    // Fonts (based on the specifications - using SF Pro)
    struct Fonts {
        static let headerBold = Font.system(size: 24, weight: .bold)
        static let headerMedium = Font.system(size: 24, weight: .medium)
        static let subheaderBold = Font.system(size: 18, weight: .bold)
        static let subheaderMedium = Font.system(size: 18, weight: .medium)
        static let bodyBold = Font.system(size: 16, weight: .bold)
        static let bodyMedium = Font.system(size: 16, weight: .medium)
        static let bodyRegular = Font.system(size: 16, weight: .regular)
        static let captionMedium = Font.system(size: 12, weight: .medium)
        static let captionRegular = Font.system(size: 12, weight: .regular)
    }
    
    // Layout dimensions
    struct Layout {
        // Standard paddings
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let cardCornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let standardCardHeight: CGFloat = 120
        static let largeCardHeight: CGFloat = 160
        
        // Corner radius
        static let cornerRadius: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 8
        
        // Button dimensions
        static let standardButtonHeight: CGFloat = 44
        static let standardButtonWidth: CGFloat = 200
        
        // Tab bar
        static let tabBarHeight: CGFloat = 49
    }
    
    // Animation durations
    struct Animation {
        static let standard: Double = 0.3
        static let long: Double = 0.4
        static let short: Double = 0.2
    }
    
    // Screen names
    struct Screens {
        static let dashboard = "Dashboard"
        static let bills = "Bills"
        static let maintenance = "Maintenance"
        static let profile = "Profile"
    }
    
    // Firebase collections
    struct Collections {
        static let users = "users"
        static let properties = "properties"
        static let bills = "bills"
        static let maintenance = "maintenance"
    }
}

// Extension to initialize Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 