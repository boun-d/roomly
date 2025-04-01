import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUpSheet = false
    @State private var showingForgotPasswordSheet = false
    
    var body: some View {
        ZStack {
            Constants.Colors.lightGray.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Constants.Layout.standardPadding * 2) {
                    // App Logo
                    VStack(spacing: Constants.Layout.smallPadding) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Constants.Colors.primaryBlue)
                            .padding(.bottom, Constants.Layout.smallPadding)
                        
                        Text("Roomly")
                            .font(Constants.Fonts.headerBold)
                            .foregroundColor(Constants.Colors.darkText)
                        
                        Text("Property Management Made Easy")
                            .font(Constants.Fonts.bodyRegular)
                            .foregroundColor(Constants.Colors.grayText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.Layout.standardPadding)
                    }
                    .padding(.top, Constants.Layout.standardPadding * 2)
                    
                    // Login Form
                    VStack(spacing: Constants.Layout.standardPadding) {
                        // Email field
                        TextField("Email", text: $email)
                            .font(Constants.Fonts.bodyRegular)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Constants.Layout.cardCornerRadius)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        // Password field
                        SecureField("Password", text: $password)
                            .font(Constants.Fonts.bodyRegular)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Constants.Layout.cardCornerRadius)
                        
                        // Forgot password link
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showingForgotPasswordSheet = true
                            }) {
                                Text("Forgot Password?")
                                    .font(Constants.Fonts.captionMedium)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            }
                        }
                        
                        // Error message
                        if let error = authService.error {
                            Text(error)
                                .font(Constants.Fonts.captionMedium)
                                .foregroundColor(Constants.Colors.error)
                                .padding(.vertical, Constants.Layout.smallPadding)
                        }
                        
                        // Sign In button
                        PrimaryButton(
                            title: "Sign In",
                            action: {
                                authService.signIn(email: email, password: password)
                            },
                            isLoading: authService.isLoading
                        )
                        .padding(.top, Constants.Layout.smallPadding)
                        
                        // Sign up prompt
                        HStack {
                            Text("Don't have an account?")
                                .font(Constants.Fonts.bodyRegular)
                                .foregroundColor(Constants.Colors.grayText)
                            
                            Button(action: {
                                showingSignUpSheet = true
                            }) {
                                Text("Sign Up")
                                    .font(Constants.Fonts.bodyMedium)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            }
                        }
                        .padding(.top, Constants.Layout.smallPadding)
                    }
                    .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    // Demo credentials
                    VStack(spacing: Constants.Layout.smallPadding) {
                        Text("Demo Credentials")
                            .font(Constants.Fonts.captionMedium)
                            .foregroundColor(Constants.Colors.grayText)
                        
                        HStack(spacing: Constants.Layout.standardPadding) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tenant:")
                                    .font(Constants.Fonts.captionMedium)
                                    .foregroundColor(Constants.Colors.grayText)
                                
                                Text("tenant@roomly.com")
                                    .font(Constants.Fonts.captionRegular)
                                    .foregroundColor(Constants.Colors.darkText)
                                
                                Text("password")
                                    .font(Constants.Fonts.captionRegular)
                                    .foregroundColor(Constants.Colors.darkText)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Landlord:")
                                    .font(Constants.Fonts.captionMedium)
                                    .foregroundColor(Constants.Colors.grayText)
                                
                                Text("landlord@roomly.com")
                                    .font(Constants.Fonts.captionRegular)
                                    .foregroundColor(Constants.Colors.darkText)
                                
                                Text("password")
                                    .font(Constants.Fonts.captionRegular)
                                    .foregroundColor(Constants.Colors.darkText)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(Constants.Layout.cardCornerRadius)
                    }
                    .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    Spacer()
                }
            }
            
            // Loading overlay
            if authService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showingSignUpSheet) {
            SignUpView()
                .environmentObject(authService)
        }
        .sheet(isPresented: $showingForgotPasswordSheet) {
            ForgotPasswordView()
                .environmentObject(authService)
        }
    }
}

// Sign Up View
struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var authService: AuthService
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var role: UserRole = .tenant
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.Layout.standardPadding) {
                        // Form
                        VStack(spacing: Constants.Layout.standardPadding) {
                            TextField("Full Name", text: $name)
                                .font(Constants.Fonts.bodyRegular)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Constants.Layout.cardCornerRadius)
                            
                            TextField("Email", text: $email)
                                .font(Constants.Fonts.bodyRegular)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Constants.Layout.cardCornerRadius)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            SecureField("Password", text: $password)
                                .font(Constants.Fonts.bodyRegular)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Constants.Layout.cardCornerRadius)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .font(Constants.Fonts.bodyRegular)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Constants.Layout.cardCornerRadius)
                            
                            // Role Selection
                            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                                Text("I am a:")
                                    .font(Constants.Fonts.bodyMedium)
                                    .foregroundColor(Constants.Colors.darkText)
                                
                                HStack {
                                    Spacer()
                                    
                                    // Tenant Button
                                    Button(action: {
                                        role = .tenant
                                    }) {
                                        VStack {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(role == .tenant ? .white : Constants.Colors.primaryBlue)
                                                .padding(.bottom, 4)
                                            
                                            Text("Tenant")
                                                .font(Constants.Fonts.bodyMedium)
                                                .foregroundColor(role == .tenant ? .white : Constants.Colors.primaryBlue)
                                        }
                                        .frame(width: 120, height: 80)
                                        .background(role == .tenant ? Constants.Colors.primaryBlue : Color.white)
                                        .cornerRadius(Constants.Layout.cardCornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                                                .stroke(Constants.Colors.primaryBlue, lineWidth: 1)
                                        )
                                    }
                                    
                                    Spacer()
                                    
                                    // Landlord Button
                                    Button(action: {
                                        role = .landlord
                                    }) {
                                        VStack {
                                            Image(systemName: "building.2.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(role == .landlord ? .white : Constants.Colors.primaryBlue)
                                                .padding(.bottom, 4)
                                            
                                            Text("Landlord")
                                                .font(Constants.Fonts.bodyMedium)
                                                .foregroundColor(role == .landlord ? .white : Constants.Colors.primaryBlue)
                                        }
                                        .frame(width: 120, height: 80)
                                        .background(role == .landlord ? Constants.Colors.primaryBlue : Color.white)
                                        .cornerRadius(Constants.Layout.cardCornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                                                .stroke(Constants.Colors.primaryBlue, lineWidth: 1)
                                        )
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(.vertical, Constants.Layout.smallPadding)
                            
                            // Error message
                            if showError {
                                Text(errorMessage)
                                    .font(Constants.Fonts.captionMedium)
                                    .foregroundColor(Constants.Colors.error)
                                    .padding(.vertical, Constants.Layout.smallPadding)
                            }
                            
                            // Sign Up button
                            PrimaryButton(
                                title: "Sign Up",
                                action: {
                                    signUp()
                                },
                                isLoading: authService.isLoading
                            )
                            .padding(.top, Constants.Layout.smallPadding)
                        }
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        .padding(.top, Constants.Layout.standardPadding)
                        
                        Spacer()
                    }
                }
                
                // Loading overlay
                if authService.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func signUp() {
        // Validate inputs
        if name.isEmpty || email.isEmpty || password.isEmpty {
            showError = true
            errorMessage = "All fields are required"
            return
        }
        
        if password != confirmPassword {
            showError = true
            errorMessage = "Passwords do not match"
            return
        }
        
        if password.count < 6 {
            showError = true
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        // Proceed with sign up
        showError = false
        authService.signUp(name: name, email: email, password: password, role: role)
    }
}

// Forgot Password View
struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(Constants.Colors.grayText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        .padding(.top, Constants.Layout.standardPadding)
                    
                    TextField("Email", text: $email)
                        .font(Constants.Fonts.bodyRegular)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(Constants.Layout.cardCornerRadius)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    // Error message
                    if let error = authService.error {
                        Text(error)
                            .font(Constants.Fonts.captionMedium)
                            .foregroundColor(Constants.Colors.error)
                            .padding(.vertical, Constants.Layout.smallPadding)
                    }
                    
                    // Success message
                    if showSuccess {
                        Text("Password reset instructions have been sent to your email.")
                            .font(Constants.Fonts.captionMedium)
                            .foregroundColor(Constants.Colors.success)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, Constants.Layout.smallPadding)
                            .padding(.horizontal, Constants.Layout.standardPadding)
                    }
                    
                    PrimaryButton(
                        title: "Reset Password",
                        action: {
                            resetPassword()
                        },
                        isLoading: authService.isLoading
                    )
                    .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    Spacer()
                }
                
                // Loading overlay
                if authService.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func resetPassword() {
        if email.isEmpty {
            authService.error = "Email is required"
            return
        }
        
        authService.resetPassword(email: email) { success in
            if success {
                showSuccess = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
} 