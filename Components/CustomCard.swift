import SwiftUI

struct CustomCard<Content: View>: View {
    var height: CGFloat?
    let content: Content
    
    init(height: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, minHeight: height)
            .background(Color.white)
            .cornerRadius(Constants.Layout.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        CustomCard {
            Text("Standard Card")
                .padding()
        }
        .padding()
        
        CustomCard(height: 150) {
            VStack {
                Text("Card with Fixed Height")
                    .font(Constants.Fonts.bodyMedium)
                Spacer()
                Text("Bottom Text")
                    .font(Constants.Fonts.captionRegular)
            }
            .padding()
        }
        .padding()
    }
} 