import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @AppStorage("onboarded") private var hasOnboarded = false
    
    var body: some View {
        ZStack {
            // Content based on authentication state
            if !hasOnboarded {
                OnboardingView(onCompleteOnboarding: {
                    hasOnboarded = true
                })
            } else if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
        .animation(.easeInOut, value: hasOnboarded)
    }
}

#Preview {
    ContentView()
} 