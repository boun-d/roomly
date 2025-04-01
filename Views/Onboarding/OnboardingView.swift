import SwiftUI

struct OnboardingView: View {
    let onCompleteOnboarding: () -> Void
    @State private var currentPage = 0
    
    // Onboarding content
    private let pages = [
        OnboardingPage(
            title: "Welcome to Roomly",
            description: "The all-in-one property management app for landlords and tenants.",
            imageName: "house.fill"
        ),
        OnboardingPage(
            title: "Simple Rent Management",
            description: "Send and receive rent payments with ease, and keep track of payment history.",
            imageName: "dollarsign.circle.fill"
        ),
        OnboardingPage(
            title: "Maintenance Made Easy",
            description: "Submit, track, and resolve maintenance requests all in one place.",
            imageName: "wrench.fill"
        ),
        OnboardingPage(
            title: "Stay Connected",
            description: "Direct communication between landlords and tenants for a better rental experience.",
            imageName: "message.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Constants.Colors.lightGray.ignoresSafeArea()
            
            VStack {
                // Page control indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Constants.Colors.primaryBlue : Constants.Colors.grayText.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 40)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 40) {
                            Image(systemName: pages[index].imageName)
                                .font(.system(size: 100))
                                .foregroundColor(Constants.Colors.primaryBlue)
                                .padding(.bottom, 20)
                            
                            Text(pages[index].title)
                                .font(Constants.Fonts.headerBold)
                                .foregroundColor(Constants.Colors.darkText)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(Constants.Fonts.bodyRegular)
                                .foregroundColor(Constants.Colors.grayText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    // Skip button
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            onCompleteOnboarding()
                        }) {
                            Text("Skip")
                                .font(Constants.Fonts.bodyMedium)
                                .foregroundColor(Constants.Colors.grayText)
                        }
                    }
                    
                    Spacer()
                    
                    // Next/Get Started button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onCompleteOnboarding()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(Constants.Fonts.bodyMedium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.primaryBlue)
                            .cornerRadius(Constants.Layout.cardCornerRadius)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

// Onboarding page model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    OnboardingView(onCompleteOnboarding: {})
} 