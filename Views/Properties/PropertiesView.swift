import SwiftUI

struct PropertiesView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = PropertiesViewModel()
    @State private var showAddProperty = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    // Header
                    Text("Properties")
                        .font(Constants.Fonts.headerBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Constants.Layout.standardPadding)
                    
                    // Properties list or empty state
                    if viewModel.properties.isEmpty {
                        VStack {
                            Spacer()
                            
                            Image(systemName: "house")
                                .font(.system(size: 50))
                                .foregroundColor(Constants.Colors.primaryBlue.opacity(0.7))
                                .padding(.bottom, Constants.Layout.standardPadding)
                            
                            Text("No Properties Yet")
                                .font(Constants.Fonts.subheaderMedium)
                                .foregroundColor(Constants.Colors.darkText)
                                .padding(.bottom, 4)
                            
                            Text("Add a property to get started")
                                .font(Constants.Fonts.bodyRegular)
                                .foregroundColor(Constants.Colors.grayText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Constants.Layout.standardPadding)
                            
                            Spacer()
                            
                            PrimaryButton(
                                title: "Add Property",
                                action: {
                                    showAddProperty = true
                                }
                            )
                            .padding(.horizontal, Constants.Layout.standardPadding)
                            .padding(.bottom, Constants.Layout.standardPadding)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Constants.Layout.smallPadding) {
                                ForEach(viewModel.properties) { property in
                                    NavigationLink(destination: PropertyDetailView(property: property)) {
                                        PropertyCard(property: property)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, Constants.Layout.standardPadding)
                        }
                        
                        // Add property button (when properties exist)
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showAddProperty = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Constants.Colors.primaryBlue)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .padding(.trailing, Constants.Layout.standardPadding)
                            .padding(.bottom, Constants.Layout.standardPadding)
                        }
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
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showAddProperty) {
                AddPropertyView(onAdd: { newProperty in
                    viewModel.addProperty(newProperty)
                    showAddProperty = false
                }, onCancel: {
                    showAddProperty = false
                })
            }
        }
        .onAppear {
            if authService.user?.isLandlord == true {
                viewModel.loadProperties()
            }
        }
    }
}

// Property Card Component
struct PropertyCard: View {
    let property: Property
    
    var body: some View {
        CustomCard {
            VStack(alignment: .leading, spacing: Constants.Layout.smallPadding) {
                // Property Image
                ZStack(alignment: .topTrailing) {
                    if let image = property.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius - 4))
                    } else {
                        Rectangle()
                            .fill(Constants.Colors.lightGray)
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "house.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Constants.Colors.grayText)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius - 4))
                    }
                    
                    // Status indicators
                    if !property.tenants.isEmpty {
                        Text("Occupied")
                            .font(Constants.Fonts.captionMedium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.success)
                            .cornerRadius(4)
                            .padding(8)
                    } else {
                        Text("Vacant")
                            .font(Constants.Fonts.captionMedium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.warning)
                            .cornerRadius(4)
                            .padding(8)
                    }
                }
                
                // Property Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.address)
                        .font(Constants.Fonts.subheaderMedium)
                        .foregroundColor(Constants.Colors.darkText)
                        .lineLimit(1)
                    
                    Text("\(property.bedrooms) bed • \(property.bathrooms) bath • \(property.squareFeet) sq ft")
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(Constants.Colors.grayText)
                    
                    // Property metrics
                    HStack(spacing: Constants.Layout.standardPadding) {
                        PropertyMetric(
                            icon: "person.2.fill",
                            value: property.tenants.count.description,
                            label: "Tenants"
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        PropertyMetric(
                            icon: "dollarsign.circle.fill",
                            value: "$\(property.rent)",
                            label: "Rent"
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        PropertyMetric(
                            icon: "wrench.fill",
                            value: property.maintenanceCount.description,
                            label: "Issues"
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, Constants.Layout.smallPadding)
                .padding(.bottom, Constants.Layout.smallPadding)
            }
        }
    }
}

// Property Metric Component
struct PropertyMetric: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.primaryBlue)
                
                Text(value)
                    .font(Constants.Fonts.bodyMedium)
                    .foregroundColor(Constants.Colors.darkText)
            }
            
            Text(label)
                .font(Constants.Fonts.captionRegular)
                .foregroundColor(Constants.Colors.grayText)
        }
    }
}

// Add Property View
struct AddPropertyView: View {
    let onAdd: (Property) -> Void
    let onCancel: () -> Void
    
    @State private var address = ""
    @State private var rent = ""
    @State private var bedrooms = ""
    @State private var bathrooms = ""
    @State private var squareFeet = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Address", text: $address)
                    TextField("Rent", text: $rent)
                        .keyboardType(.numberPad)
                    TextField("Bedrooms", text: $bedrooms)
                        .keyboardType(.numberPad)
                    TextField("Bathrooms", text: $bathrooms)
                        .keyboardType(.numberPad)
                    TextField("Square Feet", text: $squareFeet)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Add Property") {
                        let newProperty = Property(
                            id: UUID().uuidString,
                            address: address,
                            rent: Int(rent) ?? 0,
                            bedrooms: Int(bedrooms) ?? 0,
                            bathrooms: Int(bathrooms) ?? 0,
                            squareFeet: Int(squareFeet) ?? 0,
                            tenants: [],
                            maintenanceCount: 0,
                            image: nil
                        )
                        
                        onAdd(newProperty)
                    }
                    .disabled(address.isEmpty || rent.isEmpty || bedrooms.isEmpty || bathrooms.isEmpty || squareFeet.isEmpty)
                }
            }
            .navigationTitle("Add Property")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    onCancel()
                }
            )
        }
    }
}

// Properties ViewModel
class PropertiesViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func loadProperties() {
        isLoading = true
        
        // Simulating network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Load mock properties
            self.properties = [
                Property(
                    id: "1",
                    address: "123 Main St, Apartment 4B, New York, NY 10001",
                    rent: 2500,
                    bedrooms: 2,
                    bathrooms: 1,
                    squareFeet: 950,
                    tenants: ["tenant1"],
                    maintenanceCount: 2,
                    image: nil
                ),
                Property(
                    id: "2",
                    address: "456 Park Ave, Suite 7A, New York, NY 10022",
                    rent: 3200,
                    bedrooms: 3,
                    bathrooms: 2,
                    squareFeet: 1200,
                    tenants: [],
                    maintenanceCount: 0,
                    image: nil
                ),
                Property(
                    id: "3",
                    address: "789 Broadway, Unit 12C, New York, NY 10003",
                    rent: 1800,
                    bedrooms: 1,
                    bathrooms: 1,
                    squareFeet: 700,
                    tenants: ["tenant2", "tenant3"],
                    maintenanceCount: 1,
                    image: nil
                )
            ]
            
            self.isLoading = false
        }
    }
    
    func addProperty(_ property: Property) {
        isLoading = true
        
        // Simulating network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.properties.append(property)
            self.isLoading = false
        }
    }
}

// Mock Property Detail View (to be implemented in another file)
struct PropertyDetailView: View {
    let property: Property
    
    var body: some View {
        Text("Property Detail View for \(property.address)")
            .navigationTitle("Property Details")
    }
}

#Preview {
    PropertiesView()
        .environmentObject(AuthService())
} 