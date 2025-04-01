import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.Layout.standardPadding) {
                        // Header
                        Text(Constants.appName)
                            .font(Constants.Fonts.headerBold)
                            .foregroundColor(Constants.Colors.darkText)
                            .padding(.top, Constants.Layout.standardPadding)
                        
                        if let user = authService.user {
                            // Show different dashboard based on user role
                            if user.isTenant {
                                TenantDashboardContent(viewModel: viewModel)
                            } else {
                                LandlordDashboardContent(viewModel: viewModel)
                            }
                        } else {
                            // Fallback when no user is loaded
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                        }
                    }
                    .padding(.horizontal, Constants.Layout.standardPadding)
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
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
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadDashboardData(for: authService.user)
            }
        }
    }
}

// Tenant Dashboard Content
struct TenantDashboardContent: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: Constants.Layout.standardPadding) {
            // Welcome Card
            CustomCard(height: Constants.Layout.largeCardHeight) {
                VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                    Text("Welcome, \(viewModel.userName)")
                        .font(Constants.Fonts.subheaderMedium)
                        .foregroundColor(Constants.Colors.darkText)
                    
                    if let property = viewModel.selectedProperty {
                        Text("Your rental at \(property.address)")
                            .font(Constants.Fonts.bodyRegular)
                            .foregroundColor(Constants.Colors.darkText)
                    }
                }
            }
            .transition(.opacity)
            .animation(.easeIn(duration: Constants.Animation.standard), value: viewModel.userName)
            
            // Next Bill Card
            if let nextBill = viewModel.upcomingBill {
                CustomCard(height: Constants.Layout.standardCardHeight) {
                    VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                        Text("Next Bill: \(nextBill.formattedAmount())")
                            .font(Constants.Fonts.subheaderMedium)
                            .foregroundColor(Constants.Colors.darkText)
                        
                        Text("Due \(nextBill.formattedDueDate())")
                            .font(Constants.Fonts.bodyRegular)
                            .foregroundColor(nextBill.isOverdue() ? Constants.Colors.error : Constants.Colors.darkText)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .animation(.easeIn(duration: Constants.Animation.standard).delay(0.1), value: viewModel.upcomingBill)
            }
            
            // Upcoming Maintenance
            if let maintenance = viewModel.upcomingMaintenance {
                CustomCard(height: Constants.Layout.standardCardHeight) {
                    VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                        Text("Next Maintenance: \(maintenance.description)")
                            .font(Constants.Fonts.subheaderMedium)
                            .foregroundColor(Constants.Colors.darkText)
                            .lineLimit(1)
                        
                        Text(maintenance.formattedDate())
                            .font(Constants.Fonts.bodyRegular)
                            .foregroundColor(Constants.Colors.darkText)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .animation(.easeIn(duration: Constants.Animation.standard).delay(0.2), value: viewModel.upcomingMaintenance)
            }
            
            Spacer()
        }
    }
}

// Landlord Dashboard Content
struct LandlordDashboardContent: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var selectedProperty: Property?
    @State private var showingPropertyDetail = false
    
    var body: some View {
        VStack(spacing: Constants.Layout.standardPadding) {
            Text("Your Properties")
                .font(Constants.Fonts.subheaderMedium)
                .foregroundColor(Constants.Colors.darkText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.properties.isEmpty {
                Text("No properties found. Add your first property.")
                    .font(Constants.Fonts.bodyRegular)
                    .foregroundColor(Constants.Colors.darkText)
                    .padding()
                
                PrimaryButton(title: "Add Property", action: {
                    // This would show a form to add a property
                    // For demo, we'll use mock data
                    viewModel.addMockProperty()
                })
            } else {
                // Property List
                VStack(spacing: Constants.Layout.smallPadding) {
                    ForEach(viewModel.properties) { property in
                        PropertyListItem(property: property)
                            .onTapGesture {
                                selectedProperty = property
                                showingPropertyDetail = true
                            }
                            .transition(.opacity)
                            .animation(.easeIn(duration: Constants.Animation.standard), value: viewModel.properties)
                    }
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingPropertyDetail) {
            if let property = selectedProperty {
                PropertyDetailView(property: property)
            }
        }
    }
}

// Property List Item
struct PropertyListItem: View {
    let property: Property
    
    var body: some View {
        CustomCard(height: Constants.Layout.standardCardHeight) {
            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                Text(property.address)
                    .font(Constants.Fonts.subheaderMedium)
                    .foregroundColor(Constants.Colors.darkText)
                    .lineLimit(1)
                
                // Getting tenant names would require additional data loading
                // This is simplified for the demo
                Text("\(property.tenantIds.count) tenant(s)")
                    .font(Constants.Fonts.bodyRegular)
                    .foregroundColor(Constants.Colors.darkText)
            }
        }
    }
}

// Property Detail View (for landlords)
struct PropertyDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let property: Property
    @State private var showAddBill = false
    @State private var showAddMaintenance = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.Layout.standardPadding) {
                        // Property Address
                        Text(property.address)
                            .font(Constants.Fonts.headerBold)
                            .foregroundColor(Constants.Colors.darkText)
                            .padding(.top, Constants.Layout.standardPadding)
                        
                        // Tenant Info
                        CustomCard(height: Constants.Layout.smallCardHeight) {
                            VStack(alignment: .leading) {
                                Text("Tenant: \(property.tenantIds.count) tenant(s)")
                                    .font(Constants.Fonts.bodyRegular)
                                    .foregroundColor(Constants.Colors.darkText)
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: Constants.Layout.smallPadding) {
                            PrimaryButton(
                                title: "Add Bill",
                                action: { showAddBill = true }
                            )
                            
                            PrimaryButton(
                                title: "Add Maintenance",
                                action: { showAddMaintenance = true }
                            )
                        }
                        .padding(.vertical, Constants.Layout.smallPadding)
                    }
                    .padding(.horizontal, Constants.Layout.standardPadding)
                }
                
                // Mock sheets for demo
                if showAddBill {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showAddBill = false
                        }
                    
                    VStack {
                        Text("Add Bill Form")
                            .font(Constants.Fonts.headerBold)
                            .padding()
                        
                        Text("This would be a form to add a new bill")
                            .font(Constants.Fonts.bodyRegular)
                            .padding()
                        
                        PrimaryButton(title: "Close", action: {
                            showAddBill = false
                        })
                    }
                    .frame(width: 300, height: 200)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius)
                    .shadow(radius: 10)
                }
                
                if showAddMaintenance {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showAddMaintenance = false
                        }
                    
                    VStack {
                        Text("Add Maintenance Form")
                            .font(Constants.Fonts.headerBold)
                            .padding()
                        
                        Text("This would be a form to add maintenance")
                            .font(Constants.Fonts.bodyRegular)
                            .padding()
                        
                        PrimaryButton(title: "Close", action: {
                            showAddMaintenance = false
                        })
                    }
                    .frame(width: 300, height: 200)
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius)
                    .shadow(radius: 10)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(Constants.Fonts.bodyMedium)
                    .foregroundColor(Constants.Colors.primaryBlue)
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// ViewModel for Dashboard
class DashboardViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var selectedProperty: Property?
    @Published var upcomingBill: Bill?
    @Published var upcomingMaintenance: Maintenance?
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Dependencies (would be injected in a real app)
    // private let propertyService = PropertyService()
    // private let billService = BillService()
    // private let maintenanceService = MaintenanceService()
    
    func loadDashboardData(for user: User?) {
        guard let user = user else { return }
        
        isLoading = true
        error = nil
        
        // Set the user name
        userName = user.name
        
        // For demo purposes, we'll load mock data
        loadMockData(for: user)
        
        isLoading = false
    }
    
    // For demo purposes, load mock data
    private func loadMockData(for user: User) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            if user.isTenant {
                // Load tenant mock data
                self.loadMockTenantData()
            } else {
                // Load landlord mock data
                self.loadMockLandlordData()
            }
            
            self.isLoading = false
        }
    }
    
    // Load mock data for tenant
    private func loadMockTenantData() {
        // Mock property
        let property = Property(
            id: "property-1",
            address: "123 Main St, Apt 4B",
            landlordId: "landlord-1",
            tenantIds: ["tenant-1"]
        )
        
        // Mock upcoming bill
        let bill = Bill(
            id: "bill-1",
            propertyId: "property-1",
            amount: 1250.00,
            dueDate: Timestamp(date: Date().addingTimeInterval(60 * 60 * 24 * 5)), // 5 days from now
            status: .due,
            description: "Rent for July"
        )
        
        // Mock upcoming maintenance
        let maintenance = Maintenance(
            id: "maintenance-1",
            propertyId: "property-1",
            description: "Plumber visit to fix sink",
            date: Timestamp(date: Date().addingTimeInterval(60 * 60 * 24 * 2)), // 2 days from now
            status: .scheduled
        )
        
        self.selectedProperty = property
        self.upcomingBill = bill
        self.upcomingMaintenance = maintenance
    }
    
    // Load mock data for landlord
    private func loadMockLandlordData() {
        let properties = [
            Property(
                id: "property-1",
                address: "123 Main St, Apt 4B",
                landlordId: "landlord-1",
                tenantIds: ["tenant-1"]
            ),
            Property(
                id: "property-2",
                address: "456 Oak Ave, Unit 7",
                landlordId: "landlord-1",
                tenantIds: ["tenant-2", "tenant-3"]
            )
        ]
        
        self.properties = properties
    }
    
    // Add a mock property for demo
    func addMockProperty() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            let newProperty = Property(
                id: "property-\(Int.random(in: 100...999))",
                address: "789 Pine St, Unit \(Int.random(in: 1...20))",
                landlordId: "landlord-1",
                tenantIds: []
            )
            
            self.properties.append(newProperty)
            self.isLoading = false
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
} 