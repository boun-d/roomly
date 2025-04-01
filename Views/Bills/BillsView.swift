import SwiftUI

struct BillsView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = BillsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    // Header
                    Text("Bills")
                        .font(Constants.Fonts.headerBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Constants.Layout.standardPadding)
                    
                    // Filter Bar
                    FilterBar(selectedFilter: $viewModel.selectedFilter)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    if viewModel.filteredBills.isEmpty {
                        // Empty state
                        VStack {
                            Spacer()
                            
                            Text("No bills found")
                                .font(Constants.Fonts.subheaderMedium)
                                .foregroundColor(Constants.Colors.darkText)
                                .padding()
                            
                            Text("There are no bills in this category")
                                .font(Constants.Fonts.bodyRegular)
                                .foregroundColor(Constants.Colors.darkText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Constants.Layout.standardPadding)
                            
                            // For landlords, show an add bill button
                            if let user = authService.user, user.isLandlord {
                                PrimaryButton(title: "Add Bill", action: {
                                    viewModel.showAddBillSheet = true
                                })
                                .padding(.top, Constants.Layout.standardPadding)
                            }
                            
                            Spacer()
                        }
                    } else {
                        // Bills List
                        ScrollView {
                            VStack(spacing: Constants.Layout.smallPadding) {
                                ForEach(viewModel.filteredBills) { bill in
                                    BillListItem(
                                        bill: bill,
                                        isLandlord: authService.user?.isLandlord ?? false,
                                        onMarkAsPaid: {
                                            viewModel.markBillAsPaid(bill: bill)
                                        },
                                        onEdit: {
                                            viewModel.selectBillForEdit(bill: bill)
                                        },
                                        onDelete: {
                                            viewModel.showDeleteConfirmation(for: bill)
                                        }
                                    )
                                    .transition(.opacity)
                                    .animation(.easeIn(duration: Constants.Animation.standard), value: viewModel.filteredBills)
                                }
                            }
                            .padding(.horizontal, Constants.Layout.standardPadding)
                        }
                        
                        // For landlords, show a floating add button
                        if let user = authService.user, user.isLandlord {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    viewModel.showAddBillSheet = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Constants.Colors.primaryBlue)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                }
                                .padding()
                            }
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
                viewModel.loadBills(for: authService.user)
            }
            .sheet(isPresented: $viewModel.showAddBillSheet) {
                // Mock add bill form for demo
                AddBillView(isPresented: $viewModel.showAddBillSheet, onSave: { bill in
                    viewModel.addBill(bill)
                })
            }
            .sheet(item: $viewModel.selectedBill) { bill in
                // Mock edit bill form for demo
                EditBillView(bill: bill, isPresented: .constant(true), onSave: { updatedBill in
                    viewModel.updateBill(updatedBill)
                }, onDismiss: {
                    viewModel.selectedBill = nil
                })
            }
            .alert(isPresented: $viewModel.showingDeleteAlert) {
                Alert(
                    title: Text("Delete Bill"),
                    message: Text("Are you sure you want to delete this bill? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteBill()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// Filter Bar Component
struct FilterBar: View {
    @Binding var selectedFilter: BillFilter
    
    var body: some View {
        HStack(spacing: Constants.Layout.standardPadding) {
            ForEach(BillFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeIn(duration: Constants.Animation.short)) {
                        selectedFilter = filter
                    }
                }) {
                    Text(filter.rawValue)
                        .font(Constants.Fonts.bodyMedium)
                        .foregroundColor(selectedFilter == filter ? Constants.Colors.primaryBlue : Constants.Colors.darkText)
                        .padding(.bottom, 5)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(selectedFilter == filter ? Constants.Colors.primaryBlue : Color.clear),
                            alignment: .bottom
                        )
                }
            }
        }
        .frame(width: Constants.Layout.cardWidth, height: 40)
    }
}

// Bill List Item Component
struct BillListItem: View {
    let bill: Bill
    let isLandlord: Bool
    let onMarkAsPaid: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        CustomCard(height: Constants.Layout.standardCardHeight) {
            HStack {
                // Bill Info
                VStack(alignment: .leading, spacing: Constants.Layout.tinyPadding) {
                    Text("\(bill.formattedAmount()) - \(bill.description)")
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(Constants.Colors.darkText)
                        .lineLimit(1)
                    
                    Text(bill.formattedDueDate())
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(billStatusColor(bill.status))
                }
                
                Spacer()
                
                // Status and Actions
                HStack {
                    // Status Indicator
                    Circle()
                        .fill(billStatusColor(bill.status))
                        .frame(width: 10, height: 10)
                    
                    // For tenants - Mark as Paid button if bill is due/overdue
                    if !isLandlord && bill.status != .paid {
                        Button(action: onMarkAsPaid) {
                            Text("Pay")
                                .font(Constants.Fonts.bodyMedium)
                                .foregroundColor(Constants.Colors.primaryBlue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Constants.Colors.primaryBlue, lineWidth: 1)
                                )
                        }
                    }
                    
                    // For landlords - Edit options
                    if isLandlord {
                        Button(action: {
                            showingOptions = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Constants.Colors.darkText)
                                .padding(8)
                        }
                        .actionSheet(isPresented: $showingOptions) {
                            ActionSheet(
                                title: Text("Bill Options"),
                                buttons: [
                                    .default(Text("Edit Bill")) { onEdit() },
                                    .destructive(Text("Delete")) { onDelete() },
                                    .cancel()
                                ]
                            )
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // In a real app, this would open a PDF viewer if there's a PDF
            // For demo, we'll just print to console
            print("Tapped on bill: \(bill.description)")
        }
    }
    
    private func billStatusColor(_ status: BillStatus) -> Color {
        switch status {
        case .paid:
            return Constants.Colors.success
        case .overdue:
            return Constants.Colors.error
        case .due:
            return Constants.Colors.darkText
        }
    }
}

// Mock Add Bill View for demo purposes
struct AddBillView: View {
    @Binding var isPresented: Bool
    let onSave: (Bill) -> Void
    
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bill Details")) {
                    TextField("Description", text: $description)
                    TextField("Amount ($)", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Bill")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    // Create a new bill and pass it back
                    let newBill = Bill(
                        id: UUID().uuidString,
                        propertyId: "demo-property-id",
                        amount: Double(amount) ?? 0.0,
                        dueDate: Timestamp(date: dueDate),
                        status: .due,
                        description: description
                    )
                    onSave(newBill)
                    isPresented = false
                }
                .disabled(description.isEmpty || amount.isEmpty)
            )
        }
    }
}

// Mock Edit Bill View for demo purposes
struct EditBillView: View {
    let bill: Bill
    @Binding var isPresented: Bool
    let onSave: (Bill) -> Void
    let onDismiss: () -> Void
    
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var dueDate = Date()
    @State private var status: BillStatus = .due
    
    // Statuses for picker
    let statuses: [BillStatus] = [.due, .paid, .overdue]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bill Details")) {
                    TextField("Description", text: $description)
                    TextField("Amount ($)", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Edit Bill")
            .navigationBarItems(
                leading: Button("Cancel") {
                    onDismiss()
                },
                trailing: Button("Save") {
                    // Create an updated bill and pass it back
                    var updatedBill = bill
                    updatedBill.description = description
                    updatedBill.amount = Double(amount) ?? 0.0
                    updatedBill.dueDate = Timestamp(date: dueDate)
                    updatedBill.status = status
                    
                    onSave(updatedBill)
                    onDismiss()
                }
                .disabled(description.isEmpty || amount.isEmpty)
            )
            .onAppear {
                // Initialize form with bill data
                description = bill.description
                amount = String(format: "%.2f", bill.amount)
                dueDate = bill.dueDate.dateValue()
                status = bill.status
            }
        }
    }
}

// Bill Filter Enum
enum BillFilter: String, CaseIterable {
    case all = "All"
    case due = "Due"
    case paid = "Paid"
}

// ViewModel for Bills View
class BillsViewModel: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var selectedFilter: BillFilter = .all
    @Published var isLoading = false
    @Published var error: String?
    
    // UI state
    @Published var showAddBillSheet = false
    @Published var selectedBill: Bill?
    @Published var billToDelete: Bill?
    @Published var showingDeleteAlert = false
    
    // Filtered bills based on selected filter
    var filteredBills: [Bill] {
        switch selectedFilter {
        case .all:
            return bills
        case .due:
            return bills.filter { $0.status == .due || $0.status == .overdue }
        case .paid:
            return bills.filter { $0.status == .paid }
        }
    }
    
    // Dependencies (would be injected in a real app)
    // private let billService = BillService()
    
    func loadBills(for user: User?) {
        guard let user = user else { return }
        
        isLoading = true
        error = nil
        
        // For demo purposes, we'll load mock data
        loadMockBills(for: user)
    }
    
    // For demo purposes, load mock bills
    private func loadMockBills(for user: User) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Generate mock bills
            let propertyId = "property-1"
            let currentDate = Date()
            
            let mockBills: [Bill] = [
                Bill(
                    id: "bill-1",
                    propertyId: propertyId,
                    amount: 1250.00,
                    dueDate: Timestamp(date: currentDate.addingTimeInterval(60 * 60 * 24 * 5)), // 5 days from now
                    status: .due,
                    description: "Rent for July"
                ),
                Bill(
                    id: "bill-2",
                    propertyId: propertyId,
                    amount: 150.00,
                    dueDate: Timestamp(date: currentDate.addingTimeInterval(-60 * 60 * 24 * 2)), // 2 days ago
                    status: .overdue,
                    description: "Electricity"
                ),
                Bill(
                    id: "bill-3",
                    propertyId: propertyId,
                    amount: 75.00,
                    dueDate: Timestamp(date: currentDate.addingTimeInterval(-60 * 60 * 24 * 10)), // 10 days ago
                    status: .paid,
                    description: "Water"
                ),
                Bill(
                    id: "bill-4",
                    propertyId: propertyId,
                    amount: 100.00,
                    dueDate: Timestamp(date: currentDate.addingTimeInterval(-60 * 60 * 24 * 15)), // 15 days ago
                    status: .paid,
                    description: "Internet"
                )
            ]
            
            self.bills = mockBills
            self.isLoading = false
        }
    }
    
    // Mark a bill as paid
    func markBillAsPaid(bill: Bill) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Find the bill and update it
            if let index = self.bills.firstIndex(where: { $0.id == bill.id }) {
                var updatedBill = self.bills[index]
                updatedBill.status = .paid
                self.bills[index] = updatedBill
            }
            
            self.isLoading = false
        }
    }
    
    // Add a new bill (for landlords)
    func addBill(_ bill: Bill) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Add the bill to the list
            self.bills.append(bill)
            
            self.isLoading = false
        }
    }
    
    // Select a bill for editing
    func selectBillForEdit(bill: Bill) {
        selectedBill = bill
    }
    
    // Update a bill after editing
    func updateBill(_ updatedBill: Bill) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Find the bill and update it
            if let index = self.bills.firstIndex(where: { $0.id == updatedBill.id }) {
                self.bills[index] = updatedBill
            }
            
            self.isLoading = false
        }
    }
    
    // Show delete confirmation
    func showDeleteConfirmation(for bill: Bill) {
        billToDelete = bill
        showingDeleteAlert = true
    }
    
    // Delete a bill
    func deleteBill() {
        guard let billToDelete = billToDelete else { return }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Remove the bill from the list
            self.bills.removeAll { $0.id == billToDelete.id }
            
            self.isLoading = false
            self.billToDelete = nil
        }
    }
}

#Preview {
    BillsView()
        .environmentObject(AuthService())
} 