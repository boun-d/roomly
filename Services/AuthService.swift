import Foundation
import SwiftUI

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    // Sign in with email and password
    func signIn(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Mock authentication - in a real app this would validate credentials against a backend
            if email.lowercased() == "tenant@roomly.com" && password == "password" {
                self.user = User(
                    id: "tenant-123",
                    name: "John Tenant",
                    email: email,
                    role: .tenant,
                    propertyIds: ["property-123"],
                    createdAt: "Jan 1, 2023"
                )
                self.isAuthenticated = true
            } else if email.lowercased() == "landlord@roomly.com" && password == "password" {
                self.user = User(
                    id: "landlord-123",
                    name: "Jane Landlord",
                    email: email,
                    role: .landlord,
                    propertyIds: ["property-123", "property-456", "property-789"],
                    createdAt: "Jan 1, 2023"
                )
                self.isAuthenticated = true
            } else {
                self.error = "Invalid email or password"
            }
            
            self.isLoading = false
        }
    }
    
    // Sign up with email, password, and user details
    func signUp(name: String, email: String, password: String, role: UserRole) {
        isLoading = true
        error = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real app, this would create a new user in the backend
            self.user = User(
                id: UUID().uuidString,
                name: name,
                email: email,
                role: role,
                propertyIds: [],
                createdAt: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
            )
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    // Sign out
    func signOut() {
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.user = nil
            self.isAuthenticated = false
            self.isLoading = false
        }
    }
    
    // Reset password
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        error = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // In a real app, this would send a password reset email
            if email.contains("@") {
                self.isLoading = false
                completion(true)
            } else {
                self.error = "Invalid email address"
                self.isLoading = false
                completion(false)
            }
        }
    }
} 