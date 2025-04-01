import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    // Header
                    Text("Profile")
                        .font(Constants.Fonts.headerBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Constants.Layout.standardPadding)
                    
                    if let user = authService.user {
                        // Profile Info Card
                        CustomCard(height: Constants.Layout.largeCardHeight + 20) {
                            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                                // Profile picture (placeholder circle)
                                HStack {
                                    Circle()
                                        .fill(Constants.Colors.primaryBlue)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text(user.name.prefix(1).uppercased())
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                    
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(Constants.Fonts.subheaderMedium)
                                            .foregroundColor(Constants.Colors.darkText)
                                        
                                        Text("\(user.role.rawValue.capitalized)")
                                            .font(Constants.Fonts.bodyRegular)
                                            .foregroundColor(Constants.Colors.primaryBlue)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Constants.Colors.primaryBlue.opacity(0.1))
                                            .cornerRadius(5)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .padding(.vertical, 5)
                                
                                // Email
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(Constants.Colors.primaryBlue)
                                    Text(user.email)
                                        .font(Constants.Fonts.bodyRegular)
                                        .foregroundColor(Constants.Colors.darkText)
                                }
                                
                                // Property address (if tenant) or property count (if landlord)
                                HStack {
                                    Image(systemName: user.isTenant ? "house" : "building.2")
                                        .foregroundColor(Constants.Colors.primaryBlue)
                                    
                                    if user.isTenant {
                                        Text("123 Main St, Apt 4B") // This would be fetched from the property
                                            .font(Constants.Fonts.bodyRegular)
                                            .foregroundColor(Constants.Colors.darkText)
                                    } else {
                                        Text("\(user.propertyIds.count) properties")
                                            .font(Constants.Fonts.bodyRegular)
                                            .foregroundColor(Constants.Colors.darkText)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        
                        // Settings
                        CustomCard {
                            VStack(spacing: 0) {
                                // Mock settings
                                SettingRow(title: "Notifications", icon: "bell", hasToggle: true)
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                SettingRow(title: "Dark Mode", icon: "moon", hasToggle: true)
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                SettingRow(title: "Change Password", icon: "lock")
                                    .onTapGesture {
                                        // This would open a change password screen in a real app
                                        print("Change password tapped")
                                    }
                            }
                        }
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        
                        Spacer()
                        
                        // Logout Button
                        PrimaryButton(
                            title: "Log Out",
                            action: {
                                showingLogoutAlert = true
                            },
                            backgroundColor: Constants.Colors.error
                        )
                        .padding(.bottom, Constants.Layout.standardPadding)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                    } else {
                        // Loading state
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        
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
            .navigationBarHidden(true)
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        authService.signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// Setting Row Component
struct SettingRow: View {
    let title: String
    let icon: String
    var hasToggle: Bool = false
    @State private var isOn: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            Text(title)
                .font(Constants.Fonts.bodyRegular)
                .foregroundColor(Constants.Colors.darkText)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(Constants.Colors.darkText.opacity(0.5))
            }
        }
        .padding(.horizontal, Constants.Layout.standardPadding)
        .padding(.vertical, Constants.Layout.smallPadding)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
} 