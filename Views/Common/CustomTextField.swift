import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(Constants.Fonts.bodyRegular)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.buttonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.buttonCornerRadius)
                            .stroke(Constants.Colors.lightGray, lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .font(Constants.Fonts.bodyRegular)
                    .padding()
                    .keyboardType(keyboardType)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.buttonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.buttonCornerRadius)
                            .stroke(Constants.Colors.lightGray, lineWidth: 1)
                    )
            }
        }
    }
}

// Convenience modifier to add custom text field styling
extension View {
    func customTextFieldStyle() -> some View {
        self
            .font(Constants.Fonts.bodyRegular)
            .padding()
            .background(Color.white)
            .cornerRadius(Constants.Layout.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.buttonCornerRadius)
                    .stroke(Constants.Colors.lightGray, lineWidth: 1)
            )
    }
}

struct CustomLabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(Constants.Fonts.bodyMedium)
                .foregroundColor(Constants.Colors.darkText)
            
            CustomTextField(
                placeholder: placeholder,
                text: $text,
                isSecure: isSecure,
                keyboardType: keyboardType
            )
        }
    }
} 