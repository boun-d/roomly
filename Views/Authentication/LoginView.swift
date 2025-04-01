import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authService: AuthService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    // Header
                    Text(Constants.appName)
                        .font(Constants.Fonts.headerBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .padding(.top, Constants.Layout.standardPadding * 2)
                    
                    Spacer()
                    
                    // Login form
                    VStack(spacing: Constants.Layout.standardPadding) {
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
                        
                        // Login button
                        PrimaryButton(
                            title: "Log In",
                            action: {
                                viewModel.login(email: email, password: password)
                            }
                        )
                        .padding(.top, Constants.Layout.standardPadding)
                        
                        // Sign up button
                        Button("Don't have an account? Sign Up") {
                            isShowingSignUp = true
                        }
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .padding(.top, Constants.Layout.smallPadding)
                    }
                    .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    Spacer()
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
            }
            .sheet(isPresented: $isShowingSignUp) {
                SignUpView()
            }
            .onReceive(viewModel.$isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    // Transfer the user data to the auth service
                    authService.user = viewModel.user
                    authService.isAuthenticated = true
                }
            }
        }
    }
}

// ViewModel for Login
class LoginViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let authService = AuthService()
    
    func login(email: String, password: String) {
        // Basic validation
        guard !email.isEmpty else {
            error = "Email cannot be empty"
            return
        }
        
        guard !password.isEmpty else {
            error = "Password cannot be empty"
            return
        }
        
        isLoading = true
        error = nil
        
        // In a real app, this would authenticate with Firebase
        // For demo purposes, we'll simulate authentication
        simulateAuthentication(email: email, password: password)
    }
    
    // Simulate authentication for demo purposes
    private func simulateAuthentication(email: String, password: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // For demo, accept any valid-looking email with password length >= 6
            if email.contains("@") && password.count >= 6 {
                // Create a sample user for demo
                let role: UserRole = email.contains("landlord") ? .landlord : .tenant
                self.user = User(
                    id: "demo-user-id",
                    email: email,
                    name: email.components(separatedBy: "@").first ?? "User",
                    role: role,
                    propertyIds: ["demo-property-id"]
                )
                
                self.isAuthenticated = true
                self.isLoading = false
            } else {
                self.error = "Invalid email or password"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    LoginView()
} 