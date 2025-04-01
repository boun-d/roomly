import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var width: CGFloat = Constants.Layout.standardButtonWidth
    var height: CGFloat = Constants.Layout.standardButtonHeight
    var foregroundColor: Color = .white
    var backgroundColor: Color = Constants.Colors.primaryBlue
    var cornerRadius: CGFloat = Constants.Layout.buttonCornerRadius
    var font: Font = Constants.Fonts.bodyMedium
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: Constants.Animation.short)) {
                action()
            }
        }) {
            Text(title)
                .font(font)
                .foregroundColor(foregroundColor)
                .frame(width: width, height: height)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

// Custom button style that adds a slight bounce animation
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: Constants.Animation.short), value: configuration.isPressed)
    }
}

// Extension to add primary button styling to any button
extension Button {
    func primaryButtonStyle(
        width: CGFloat = Constants.Layout.standardButtonWidth,
        height: CGFloat = Constants.Layout.standardButtonHeight,
        foregroundColor: Color = .white,
        backgroundColor: Color = Constants.Colors.primaryBlue,
        cornerRadius: CGFloat = Constants.Layout.buttonCornerRadius
    ) -> some View {
        self
            .font(Constants.Fonts.bodyMedium)
            .foregroundColor(foregroundColor)
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .buttonStyle(BouncyButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Standard Button", action: {})
        
        PrimaryButton(
            title: "Custom Button",
            action: {},
            backgroundColor: Constants.Colors.success,
            height: 60
        )
        
        Button("Styled Button", action: {})
            .primaryButtonStyle(backgroundColor: Constants.Colors.error)
    }
    .padding()
    .background(Constants.Colors.lightGray)
} 