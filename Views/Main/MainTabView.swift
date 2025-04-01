import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            // Bills Tab
            BillsView()
                .tabItem {
                    Label("Bills", systemImage: "dollarsign.circle.fill")
                }
            
            // Maintenance Tab
            MaintenanceView()
                .tabItem {
                    Label("Maintenance", systemImage: "wrench.fill")
                }
            
            // Properties Tab (Landlord only)
            if authService.user?.isLandlord == true {
                PropertiesView()
                    .tabItem {
                        Label("Properties", systemImage: "building.2.fill")
                    }
            }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(Constants.Colors.primaryBlue)
        .onAppear {
            // Set the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            // Use this appearance when scrolling behind the TabView
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
} 