import SwiftUI

struct CustomCard<Content: View>: View {
    let content: Content
    var height: CGFloat? = nil
    var width: CGFloat = Constants.Layout.cardWidth
    var cornerRadius: CGFloat = Constants.Layout.cornerRadius
    var shadowRadius: CGFloat = 5
    var shadowOpacity: Double = 0.1
    
    init(
        height: CGFloat? = nil,
        width: CGFloat = Constants.Layout.cardWidth,
        cornerRadius: CGFloat = Constants.Layout.cornerRadius,
        shadowRadius: CGFloat = 5,
        shadowOpacity: Double = 0.1,
        @ViewBuilder content: () -> Content
    ) {
        self.height = height
        self.width = width
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: width, height: height)
            .padding(Constants.Layout.smallPadding)
            .background(Constants.Colors.white)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 0)
    }
}

// Convenience modifier for adding standard card styling to any view
extension View {
    func cardStyle(
        height: CGFloat? = nil,
        width: CGFloat = Constants.Layout.cardWidth,
        cornerRadius: CGFloat = Constants.Layout.cornerRadius,
        shadowRadius: CGFloat = 5,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self
            .frame(width: width, height: height)
            .padding(Constants.Layout.smallPadding)
            .background(Constants.Colors.white)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 0)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomCard {
            VStack(alignment: .leading) {
                Text("Standard Card")
                    .font(Constants.Fonts.subheaderMedium)
                    .foregroundColor(Constants.Colors.darkText)
                
                Text("With some content")
                    .font(Constants.Fonts.bodyRegular)
                    .foregroundColor(Constants.Colors.darkText)
            }
        }
        
        Text("Card Styled Text")
            .padding()
            .cardStyle(height: 60)
    }
    .padding()
    .background(Constants.Colors.lightGray)
} 