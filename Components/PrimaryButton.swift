import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var backgroundColor: Color = Constants.Colors.primaryBlue
    var foregroundColor: Color = .white
    var fullWidth: Bool = true
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Button background and text
                HStack {
                    if fullWidth {
                        Spacer()
                    }
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                            .scaleEffect(1.0)
                    } else {
                        Text(title)
                            .font(Constants.Fonts.bodyMedium)
                            .foregroundColor(foregroundColor)
                    }
                    
                    if fullWidth {
                        Spacer()
                    }
                }
            }
            .frame(height: Constants.Layout.buttonHeight)
            .background(backgroundColor)
            .cornerRadius(Constants.Layout.cardCornerRadius)
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(
            title: "Primary Button",
            action: {
                print("Button tapped")
            }
        )
        
        PrimaryButton(
            title: "Loading Button",
            action: {},
            isLoading: true
        )
        
        PrimaryButton(
            title: "Danger Button",
            action: {},
            backgroundColor: Constants.Colors.error
        )
        
        PrimaryButton(
            title: "Custom Button",
            action: {},
            backgroundColor: Constants.Colors.success,
            fullWidth: false
        )
        .padding(.horizontal, 50)
    }
    .padding()
} 