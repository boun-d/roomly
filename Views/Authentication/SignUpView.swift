import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SignUpViewModel()
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var role: UserRole = .tenant
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    // Header
                    Text("Create Account")
                        .font(Constants.Fonts.headerBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .padding(.top, Constants.Layout.standardPadding)
                    
                    ScrollView {
                        VStack(spacing: Constants.Layout.standardPadding) {
                            // Name field
                            CustomLabeledTextField(
                                label: "Name",
                                placeholder: "Enter your full name",
                                text: $name
                            )
                            
                            // Email field
                            CustomLabeledTextField(
                                label: "Email",
                                placeholder: "Enter your email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            // Password field
                            CustomLabeledTextField(
                                label: "Password",
                                placeholder: "Enter your password",
                                text: $password,
                                isSecure: true
                            )
                            
                            // Confirm password field
                            CustomLabeledTextField(
                                label: "Confirm Password",
                                placeholder: "Confirm your password",
                                text: $confirmPassword,
                                isSecure: true
                            )
                            
                            // Role selection
                            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                                Text("Account Type")
                                    .font(Constants.Fonts.bodyMedium)
                                    .foregroundColor(Constants.Colors.darkText)
                                
                                Picker("Account Type", selection: $role) {
                                    Text("Tenant").tag(UserRole.tenant)
                                    Text("Landlord").tag(UserRole.landlord)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, Constants.Layout.smallPadding)
                            }
                            
                            // Sign up button
                            PrimaryButton(
                                title: "Sign Up",
                                action: {
                                    viewModel.signUp(
                                        name: name,
                                        email: email,
                                        password: password,
                                        confirmPassword: confirmPassword,
                                        role: role
                                    )
                                }
                            )
                            .padding(.top, Constants.Layout.standardPadding)
                            
                            // Back to login button
                            Button("Already have an account? Log In") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(Constants.Fonts.bodyMedium)
                            .foregroundColor(Constants.Colors.primaryBlue)
                            .padding(.top, Constants.Layout.smallPadding)
                        }
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        .padding(.bottom, Constants.Layout.standardPadding)
                    }
                }
                
                // Error alert
                if let error = viewModel.error {
                    VStack {
                        Spacer()
                        
                        Text(error)
                            .font(Constants.Fonts.bodyMedium)
                            .foregroundColor(.white)
                            .padding()
                            .background(Constants.Colors.error)
                            .cornerRadius(Constants.Layout.cornerRadius)
                            .padding(.bottom, Constants.Layout.standardPadding)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(response: Constants.Animation.standard), value: viewModel.error)
                    }
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
                }
                
                // Success alert
                if viewModel.isSuccess {
                    VStack {
                        Spacer()
                        
                        Text("Account created successfully!")
                            .font(Constants.Fonts.bodyMedium)
                            .foregroundColor(.white)
                            .padding()
                            .background(Constants.Colors.success)
                            .cornerRadius(Constants.Layout.cornerRadius)
                            .padding(.bottom, Constants.Layout.standardPadding)
                            .onAppear {
                                // Dismiss the view after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// ViewModel for Sign Up
class SignUpViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var isSuccess = false
    
    private let authService = AuthService()
    
    func signUp(name: String, email: String, password: String, confirmPassword: String, role: UserRole) {
        // Basic validation
        guard !name.isEmpty else {
            error = "Name cannot be empty"
            return
        }
        
        guard !email.isEmpty, email.contains("@") else {
            error = "Please enter a valid email"
            return
        }
        
        guard password.count >= 6 else {
            error = "Password must be at least 6 characters"
            return
        }
        
        guard password == confirmPassword else {
            error = "Passwords do not match"
            return
        }
        
        isLoading = true
        error = nil
        
        // In a real app, this would create a user in Firebase
        // For demo purposes, we'll simulate account creation
        simulateAccountCreation(name: name, email: email, password: password, role: role)
    }
    
    // Simulate account creation for demo purposes
    private func simulateAccountCreation(name: String, email: String, password: String, role: UserRole) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // In demo mode, always succeed unless email has "error" in it
            if email.lowercased().contains("error") {
                self.error = "Failed to create account. Try a different email."
                self.isLoading = false
            } else {
                self.isSuccess = true
                self.isLoading = false
            }
        }
    }
}

#Preview {
    SignUpView()
} 