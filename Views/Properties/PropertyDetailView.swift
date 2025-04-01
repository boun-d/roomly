import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = PropertyDetailViewModel()
    @State private var selectedTab = 0
    @State private var showAddTenant = false
    @State private var showAddBill = false
    @State private var showAddMaintenance = false
    
    var body: some View {
        ZStack {
            Constants.Colors.lightGray.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Property image or placeholder
                ZStack(alignment: .bottomLeading) {
                    if let image = property.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(Rectangle())
                    } else {
                        Rectangle()
                            .fill(Constants.Colors.primaryBlue.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "house.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Constants.Colors.primaryBlue.opacity(0.8))
                            )
                    }
                    
                    // Status indicator
                    Text(property.tenants.isEmpty ? "Vacant" : "Occupied")
                        .font(Constants.Fonts.captionMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(property.tenants.isEmpty ? Constants.Colors.warning : Constants.Colors.success)
                        .cornerRadius(4)
                        .padding(16)
                }
                
                // Property details
                VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                    Text(property.address)
                        .font(Constants.Fonts.subheaderBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    Text("\(property.bedrooms) bed • \(property.bathrooms) bath • \(property.squareFeet) sq ft")
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(Constants.Colors.grayText)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    Text("$\(property.rent)/month")
                        .font(Constants.Fonts.subheaderMedium)
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        .padding(.top, 4)
                    
                    // Tab selection
                    Picker("", selection: $selectedTab) {
                        Text("Details").tag(0)
                        Text("Tenants").tag(1)
                        Text("Bills").tag(2)
                        Text("Maintenance").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Constants.Layout.standardPadding)
                    .padding(.vertical, Constants.Layout.standardPadding)
                }
                
                // Tab content
                ScrollView {
                    VStack {
                        switch selectedTab {
                        case 0:
                            PropertyInfoTab(property: property)
                        case 1:
                            TenantListTab(
                                tenants: viewModel.tenants,
                                onAddTenant: { showAddTenant = true }
                            )
                        case 2:
                            BillsListTab(
                                bills: viewModel.bills,
                                onAddBill: { showAddBill = true }
                            )
                        case 3:
                            MaintenanceListTab(
                                maintenanceItems: viewModel.maintenanceItems,
                                onAddMaintenance: { showAddMaintenance = true }
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, Constants.Layout.standardPadding)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius, style: .continuous))
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
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showAddTenant) {
            AddTenantView(onAdd: { tenant in
                viewModel.addTenant(tenant)
                showAddTenant = false
            }, onCancel: {
                showAddTenant = false
            })
        }
        .sheet(isPresented: $showAddBill) {
            AddBillView(propertyId: property.id, onAdd: { bill in
                viewModel.addBill(bill)
                showAddBill = false
            }, onCancel: {
                showAddBill = false
            })
        }
        .sheet(isPresented: $showAddMaintenance) {
            AddMaintenanceView(propertyId: property.id, onAdd: { maintenance in
                viewModel.addMaintenance(maintenance)
                showAddMaintenance = false
            }, onCancel: {
                showAddMaintenance = false
            })
        }
        .onAppear {
            viewModel.loadData(for: property.id)
        }
    }
}

// Property Info Tab
struct PropertyInfoTab: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.standardPadding) {
            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                SectionTitle(title: "Property Details")
                
                CustomCard {
                    VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                        DetailRow(label: "Property ID", value: property.id)
                        Divider()
                        DetailRow(label: "Bedrooms", value: "\(property.bedrooms)")
                        Divider()
                        DetailRow(label: "Bathrooms", value: "\(property.bathrooms)")
                        Divider()
                        DetailRow(label: "Square Feet", value: "\(property.squareFeet)")
                        Divider()
                        DetailRow(label: "Monthly Rent", value: "$\(property.rent)")
                        Divider()
                        DetailRow(label: "Status", value: property.tenants.isEmpty ? "Vacant" : "Occupied")
                    }
                    .padding(Constants.Layout.standardPadding)
                }
            }
            .padding(.horizontal, Constants.Layout.standardPadding)
            
            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                SectionTitle(title: "Property Description")
                
                CustomCard {
                    Text("This beautiful property features modern amenities, spacious rooms, and a convenient location. The property is well-maintained and includes all essential utilities. Perfect for families or professionals looking for a comfortable living space.")
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(Constants.Colors.darkText)
                        .padding(Constants.Layout.standardPadding)
                }
            }
            .padding(.horizontal, Constants.Layout.standardPadding)
            
            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                SectionTitle(title: "Location")
                
                CustomCard {
                    // Map Placeholder
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "map")
                                .font(.system(size: 40))
                                .foregroundColor(Constants.Colors.grayText)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius - 8))
                        .padding(Constants.Layout.standardPadding)
                }
            }
            .padding(.horizontal, Constants.Layout.standardPadding)
        }
    }
}

// Tenant List Tab
struct TenantListTab: View {
    let tenants: [User]
    let onAddTenant: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.standardPadding) {
            HStack {
                SectionTitle(title: "Tenants (\(tenants.count))")
                Spacer()
                Button(action: onAddTenant) {
                    Text("Add Tenant")
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .padding(.horizontal, Constants.Layout.standardPadding)
            
            if tenants.isEmpty {
                EmptyStateView(
                    systemName: "person",
                    title: "No Tenants",
                    message: "Add tenants to this property"
                )
            } else {
                ForEach(tenants) { tenant in
                    TenantItem(tenant: tenant)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                }
            }
        }
    }
}

// Bills List Tab
struct BillsListTab: View {
    let bills: [Bill]
    let onAddBill: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.standardPadding) {
            HStack {
                SectionTitle(title: "Bills (\(bills.count))")
                Spacer()
                Button(action: onAddBill) {
                    Text("Add Bill")
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .padding(.horizontal, Constants.Layout.standardPadding)
            
            if bills.isEmpty {
                EmptyStateView(
                    systemName: "dollarsign.circle",
                    title: "No Bills",
                    message: "Add bills for this property"
                )
            } else {
                ForEach(bills) { bill in
                    BillItem(bill: bill)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                }
            }
        }
    }
}

// Maintenance List Tab
struct MaintenanceListTab: View {
    let maintenanceItems: [MaintenanceEvent]
    let onAddMaintenance: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.standardPadding) {
            HStack {
                SectionTitle(title: "Maintenance (\(maintenanceItems.count))")
                Spacer()
                Button(action: onAddMaintenance) {
                    Text("Add Maintenance")
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .padding(.horizontal, Constants.Layout.standardPadding)
            
            if maintenanceItems.isEmpty {
                EmptyStateView(
                    systemName: "wrench",
                    title: "No Maintenance",
                    message: "Add maintenance tasks for this property"
                )
            } else {
                ForEach(maintenanceItems) { item in
                    MaintenanceItem(item: item)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                }
            }
        }
    }
}

// Tenant Item
struct TenantItem: View {
    let tenant: User
    
    var body: some View {
        CustomCard {
            HStack {
                // Profile Image Placeholder
                Circle()
                    .fill(Constants.Colors.primaryBlue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(tenant.name.prefix(1).uppercased())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tenant.name)
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.darkText)
                    
                    Text(tenant.email)
                        .font(Constants.Fonts.captionRegular)
                        .foregroundColor(Constants.Colors.grayText)
                    
                    Text("Joined: \(tenant.createdAt)")
                        .font(Constants.Fonts.captionRegular)
                        .foregroundColor(Constants.Colors.grayText)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(Constants.Colors.grayText)
                    .padding()
            }
            .padding(Constants.Layout.smallPadding)
        }
    }
}

// Bill Item
struct BillItem: View {
    let bill: Bill
    
    var body: some View {
        CustomCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.title)
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.darkText)
                    
                    Text("Due: \(bill.dueDate)")
                        .font(Constants.Fonts.captionRegular)
                        .foregroundColor(Constants.Colors.grayText)
                    
                    StatusBadge(status: bill.isPaid ? "Paid" : "Unpaid", color: bill.isPaid ? Constants.Colors.success : Constants.Colors.warning)
                }
                
                Spacer()
                
                Text("$\(bill.amount)")
                    .font(Constants.Fonts.subheaderMedium)
                    .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(Constants.Layout.standardPadding)
        }
    }
}

// Maintenance Item
struct MaintenanceItem: View {
    let item: MaintenanceEvent
    
    var body: some View {
        CustomCard {
            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                HStack {
                    Text(item.title)
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(Constants.Colors.darkText)
                    
                    Spacer()
                    
                    StatusBadge(
                        status: item.status.rawValue.capitalized,
                        color: item.status == .completed ? Constants.Colors.success : 
                              item.status == .inProgress ? Constants.Colors.warning : Constants.Colors.error
                    )
                }
                
                Text(item.description)
                    .font(Constants.Fonts.bodyRegular)
                    .foregroundColor(Constants.Colors.grayText)
                    .lineLimit(2)
                
                HStack {
                    Text("Reported: \(item.createdAt)")
                        .font(Constants.Fonts.captionRegular)
                        .foregroundColor(Constants.Colors.grayText)
                    
                    Spacer()
                    
                    if item.status != .completed {
                        Button(action: {}) {
                            Text("Update Status")
                                .font(Constants.Fonts.captionMedium)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                    }
                }
            }
            .padding(Constants.Layout.standardPadding)
        }
    }
}

// Empty State View
struct EmptyStateView: View {
    let systemName: String
    let title: String
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: systemName)
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.primaryBlue.opacity(0.7))
                .padding(.bottom, Constants.Layout.standardPadding)
            
            Text(title)
                .font(Constants.Fonts.subheaderMedium)
                .foregroundColor(Constants.Colors.darkText)
                .padding(.bottom, 4)
            
            Text(message)
                .font(Constants.Fonts.bodyRegular)
                .foregroundColor(Constants.Colors.grayText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Layout.standardPadding)
            
            Spacer()
        }
        .padding()
        .frame(minHeight: 200)
    }
}

// Section Title Component
struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(Constants.Fonts.bodyBold)
            .foregroundColor(Constants.Colors.darkText)
    }
}

// Detail Row Component
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(Constants.Fonts.bodyRegular)
                .foregroundColor(Constants.Colors.grayText)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(Constants.Fonts.bodyMedium)
                .foregroundColor(Constants.Colors.darkText)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Status Badge Component
struct StatusBadge: View {
    let status: String
    let color: Color
    
    var body: some View {
        Text(status)
            .font(Constants.Fonts.captionMedium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

// PropertyDetailViewModel
class PropertyDetailViewModel: ObservableObject {
    @Published var tenants: [User] = []
    @Published var bills: [Bill] = []
    @Published var maintenanceItems: [MaintenanceEvent] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func loadData(for propertyId: String) {
        isLoading = true
        
        // Simulating network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Load mock tenants
            self.tenants = [
                User(
                    id: "tenant1",
                    name: "John Doe",
                    email: "john.doe@example.com",
                    role: .tenant,
                    propertyIds: [propertyId],
                    createdAt: "Jan 1, 2023"
                ),
                User(
                    id: "tenant2",
                    name: "Jane Smith",
                    email: "jane.smith@example.com",
                    role: .tenant,
                    propertyIds: [propertyId],
                    createdAt: "Mar 15, 2023"
                )
            ]
            
            // Load mock bills
            self.bills = [
                Bill(
                    id: "bill1",
                    title: "Rent - May 2023",
                    amount: 1500,
                    dueDate: "May 1, 2023",
                    isPaid: true,
                    propertyId: propertyId,
                    tenantId: "tenant1"
                ),
                Bill(
                    id: "bill2",
                    title: "Utilities - May 2023",
                    amount: 120,
                    dueDate: "May 5, 2023",
                    isPaid: false,
                    propertyId: propertyId,
                    tenantId: "tenant1"
                ),
                Bill(
                    id: "bill3",
                    title: "Rent - June 2023",
                    amount: 1500,
                    dueDate: "June 1, 2023",
                    isPaid: false,
                    propertyId: propertyId,
                    tenantId: "tenant1"
                )
            ]
            
            // Load mock maintenance items
            self.maintenanceItems = [
                MaintenanceEvent(
                    id: "maint1",
                    title: "Leaky Faucet",
                    description: "The kitchen faucet is leaking and needs repair.",
                    status: .completed,
                    propertyId: propertyId,
                    createdAt: "Apr 15, 2023",
                    completedAt: "Apr 18, 2023"
                ),
                MaintenanceEvent(
                    id: "maint2",
                    title: "Broken Window",
                    description: "The living room window doesn't close properly.",
                    status: .inProgress,
                    propertyId: propertyId,
                    createdAt: "May 2, 2023",
                    completedAt: nil
                ),
                MaintenanceEvent(
                    id: "maint3",
                    title: "AC Not Working",
                    description: "The air conditioning unit isn't cooling properly.",
                    status: .pending,
                    propertyId: propertyId,
                    createdAt: "May 10, 2023",
                    completedAt: nil
                )
            ]
            
            self.isLoading = false
        }
    }
    
    func addTenant(_ tenant: User) {
        tenants.append(tenant)
    }
    
    func addBill(_ bill: Bill) {
        bills.append(bill)
    }
    
    func addMaintenance(_ maintenance: MaintenanceEvent) {
        maintenanceItems.append(maintenance)
    }
}

// Mock Add Tenant View
struct AddTenantView: View {
    let onAdd: (User) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Text("Add Tenant View")
            .onAppear {
                // This is a placeholder - in a real app, you'd have a form
                onCancel()
            }
    }
}

// Mock Add Bill View
struct AddBillView: View {
    let propertyId: String
    let onAdd: (Bill) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Text("Add Bill View")
            .onAppear {
                // This is a placeholder - in a real app, you'd have a form
                onCancel()
            }
    }
}

// Mock Add Maintenance View
struct AddMaintenanceView: View {
    let propertyId: String
    let onAdd: (MaintenanceEvent) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Text("Add Maintenance View")
            .onAppear {
                // This is a placeholder - in a real app, you'd have a form
                onCancel()
            }
    }
}

#Preview {
    NavigationView {
        PropertyDetailView(
            property: Property(
                id: "1",
                address: "123 Main St, Apartment 4B, New York, NY 10001",
                rent: 2500,
                bedrooms: 2,
                bathrooms: 1,
                squareFeet: 950,
                tenants: ["tenant1"],
                maintenanceCount: 2,
                image: nil
            )
        )
        .environmentObject(AuthService())
    }
} 