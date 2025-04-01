import SwiftUI

struct MaintenanceView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = MaintenanceViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.lightGray.ignoresSafeArea()
                
                VStack(spacing: Constants.Layout.standardPadding) {
                    // Header
                    Text("Maintenance")
                        .font(Constants.Fonts.headerBold)
                        .foregroundColor(Constants.Colors.darkText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Constants.Layout.standardPadding)
                    
                    // Calendar View
                    CalendarView(selectedDate: $viewModel.selectedDate, events: viewModel.maintenanceEvents)
                        .frame(width: Constants.Layout.cardWidth, height: 200)
                        .background(Color.white)
                        .cornerRadius(Constants.Layout.cornerRadius)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                    
                    // Events for Selected Date
                    Text("Scheduled Maintenance")
                        .font(Constants.Fonts.subheaderMedium)
                        .foregroundColor(Constants.Colors.darkText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Constants.Layout.standardPadding)
                        .padding(.top, Constants.Layout.smallPadding)
                    
                    if viewModel.eventsForSelectedDate.isEmpty {
                        // Empty state
                        VStack {
                            Spacer()
                            
                            Text("No maintenance scheduled")
                                .font(Constants.Fonts.bodyRegular)
                                .foregroundColor(Constants.Colors.darkText)
                                .padding()
                            
                            if let user = authService.user, user.isLandlord {
                                PrimaryButton(title: "Schedule Maintenance", action: {
                                    viewModel.showAddMaintenanceSheet = true
                                })
                            }
                            
                            Spacer()
                        }
                        .frame(maxHeight: 200)
                    } else {
                        // Maintenance Event List
                        ScrollView {
                            VStack(spacing: Constants.Layout.smallPadding) {
                                ForEach(viewModel.eventsForSelectedDate) { event in
                                    MaintenanceEventItem(
                                        event: event,
                                        isLandlord: authService.user?.isLandlord ?? false,
                                        onStatusChange: { newStatus in
                                            viewModel.updateMaintenanceStatus(event: event, newStatus: newStatus)
                                        },
                                        onEdit: {
                                            viewModel.selectEventForEdit(event: event)
                                        },
                                        onDelete: {
                                            viewModel.showDeleteConfirmation(for: event)
                                        }
                                    )
                                    .transition(.opacity)
                                    .animation(.easeIn(duration: Constants.Animation.standard), value: viewModel.eventsForSelectedDate)
                                }
                            }
                            .padding(.horizontal, Constants.Layout.standardPadding)
                        }
                    }
                    
                    Spacer()
                    
                    // For landlords, show a floating add button
                    if let user = authService.user, user.isLandlord {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                viewModel.showAddMaintenanceSheet = true
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
                viewModel.loadMaintenanceEvents(for: authService.user)
            }
            .sheet(isPresented: $viewModel.showAddMaintenanceSheet) {
                // Mock add maintenance form for demo
                AddMaintenanceView(isPresented: $viewModel.showAddMaintenanceSheet, onSave: { event in
                    viewModel.addMaintenanceEvent(event)
                })
            }
            .sheet(item: $viewModel.selectedEvent) { event in
                // Mock edit maintenance form for demo
                EditMaintenanceView(event: event, isPresented: .constant(true), onSave: { updatedEvent in
                    viewModel.updateMaintenanceEvent(updatedEvent)
                }, onDismiss: {
                    viewModel.selectedEvent = nil
                })
            }
            .alert(isPresented: $viewModel.showingDeleteAlert) {
                Alert(
                    title: Text("Delete Maintenance"),
                    message: Text("Are you sure you want to delete this maintenance event? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteMaintenanceEvent()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// Calendar View Component
struct CalendarView: View {
    @Binding var selectedDate: Date
    let events: [Maintenance]
    
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    private let dayFormatter = DateFormatter()
    private let monthFormatter = DateFormatter()
    
    init(selectedDate: Binding<Date>, events: [Maintenance]) {
        self._selectedDate = selectedDate
        self.events = events
        
        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "MMMM yyyy"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Month header
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                Spacer()
                
                Text(monthFormatter.string(from: currentMonth))
                    .font(Constants.Fonts.subheaderMedium)
                    .foregroundColor(Constants.Colors.darkText)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .padding(.horizontal)
            
            // Day of week header
            HStack(spacing: 0) {
                ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.darkText)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if date.isInSameMonth(as: currentMonth) {
                        DayView(
                            date: date,
                            selectedDate: $selectedDate,
                            hasEvents: hasEvents(on: date)
                        )
                    } else {
                        // Empty space for days not in current month
                        Color.clear.frame(height: 30)
                    }
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    // Generate array of dates for the current month view
    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var dates: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return dates
    }
    
    // Check if there are events on a specific date
    private func hasEvents(on date: Date) -> Bool {
        return events.contains { event in
            calendar.isDate(event.date.dateValue(), inSameDayAs: date)
        }
    }
}

// Day View Component
struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date
    let hasEvents: Bool
    
    private let calendar = Calendar.current
    private let dayFormatter = DateFormatter()
    
    init(date: Date, selectedDate: Binding<Date>, hasEvents: Bool) {
        self.date = date
        self._selectedDate = selectedDate
        self.hasEvents = hasEvents
        
        dayFormatter.dateFormat = "d"
    }
    
    var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedDate = date
            }
        }) {
            ZStack {
                // Background circle for selected date
                Circle()
                    .fill(isSelected ? Constants.Colors.primaryBlue : Color.clear)
                    .frame(width: 30, height: 30)
                
                // Day number
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : isToday ? Constants.Colors.primaryBlue : Constants.Colors.darkText)
                
                // Event indicator
                if hasEvents {
                    Circle()
                        .fill(isSelected ? .white : Constants.Colors.primaryBlue)
                        .frame(width: 5, height: 5)
                        .offset(y: 12)
                }
            }
            .frame(height: 30)
        }
    }
}

// Maintenance Event Item Component
struct MaintenanceEventItem: View {
    let event: Maintenance
    let isLandlord: Bool
    let onStatusChange: (MaintenanceStatus) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        CustomCard(height: Constants.Layout.standardCardHeight) {
            HStack {
                // Event Info
                VStack(alignment: .leading, spacing: Constants.Layout.tinyPadding) {
                    Text(event.description)
                        .font(Constants.Fonts.bodyRegular)
                        .foregroundColor(Constants.Colors.darkText)
                        .lineLimit(1)
                    
                    HStack {
                        Text(event.formattedDate())
                            .font(Constants.Fonts.bodyRegular)
                            .foregroundColor(Constants.Colors.darkText)
                        
                        Text("• \(event.status.rawValue.capitalized)")
                            .font(Constants.Fonts.bodyRegular)
                            .foregroundColor(statusColor(event.status))
                    }
                    
                    if let notes = event.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.darkText.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Actions
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
                            title: Text("Maintenance Options"),
                            buttons: [
                                .default(Text("Mark as Completed")) {
                                    onStatusChange(.completed)
                                },
                                .default(Text("Edit")) {
                                    onEdit()
                                },
                                .destructive(Text("Delete")) {
                                    onDelete()
                                },
                                .cancel()
                            ]
                        )
                    }
                } else {
                    // For tenants - Status indicator only
                    Circle()
                        .fill(statusColor(event.status))
                        .frame(width: 10, height: 10)
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    private func statusColor(_ status: MaintenanceStatus) -> Color {
        switch status {
        case .scheduled:
            return Constants.Colors.primaryBlue
        case .completed:
            return Constants.Colors.success
        case .cancelled:
            return Constants.Colors.error
        }
    }
}

// Mock Add Maintenance View for demo purposes
struct AddMaintenanceView: View {
    @Binding var isPresented: Bool
    let onSave: (Maintenance) -> Void
    
    @State private var description: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Maintenance Details")) {
                    TextField("Description", text: $description)
                    TextField("Notes (optional)", text: $notes)
                    DatePicker("Date and Time", selection: $date)
                }
            }
            .navigationTitle("Schedule Maintenance")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    // Create a new maintenance event and pass it back
                    let newEvent = Maintenance(
                        id: UUID().uuidString,
                        propertyId: "demo-property-id",
                        description: description,
                        date: Timestamp(date: date),
                        status: .scheduled,
                        notes: notes.isEmpty ? nil : notes
                    )
                    onSave(newEvent)
                    isPresented = false
                }
                .disabled(description.isEmpty)
            )
        }
    }
}

// Mock Edit Maintenance View for demo purposes
struct EditMaintenanceView: View {
    let event: Maintenance
    @Binding var isPresented: Bool
    let onSave: (Maintenance) -> Void
    let onDismiss: () -> Void
    
    @State private var description: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    @State private var status: MaintenanceStatus = .scheduled
    
    // Statuses for picker
    let statuses: [MaintenanceStatus] = [.scheduled, .completed, .cancelled]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Maintenance Details")) {
                    TextField("Description", text: $description)
                    TextField("Notes (optional)", text: $notes)
                    DatePicker("Date and Time", selection: $date)
                    
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Edit Maintenance")
            .navigationBarItems(
                leading: Button("Cancel") {
                    onDismiss()
                },
                trailing: Button("Save") {
                    // Create an updated maintenance event and pass it back
                    var updatedEvent = event
                    updatedEvent.description = description
                    updatedEvent.notes = notes.isEmpty ? nil : notes
                    updatedEvent.date = Timestamp(date: date)
                    updatedEvent.status = status
                    
                    onSave(updatedEvent)
                    onDismiss()
                }
                .disabled(description.isEmpty)
            )
            .onAppear {
                // Initialize form with event data
                description = event.description
                notes = event.notes ?? ""
                date = event.date.dateValue()
                status = event.status
            }
        }
    }
}

// Extension to help with date comparison
extension Date {
    func isInSameMonth(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: self) == calendar.component(.month, from: date) &&
               calendar.component(.year, from: self) == calendar.component(.year, from: date)
    }
}

// Extension to make Maintenance identifiable for sheet presentation
extension Maintenance: Identifiable {}

// ViewModel for Maintenance View
class MaintenanceViewModel: ObservableObject {
    @Published var maintenanceEvents: [Maintenance] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var error: String?
    
    // UI state
    @Published var showAddMaintenanceSheet = false
    @Published var selectedEvent: Maintenance?
    @Published var eventToDelete: Maintenance?
    @Published var showingDeleteAlert = false
    
    // Computed property to get events for the selected date
    var eventsForSelectedDate: [Maintenance] {
        let calendar = Calendar.current
        return maintenanceEvents.filter { event in
            calendar.isDate(event.date.dateValue(), inSameDayAs: selectedDate)
        }
    }
    
    // Dependencies (would be injected in a real app)
    // private let maintenanceService = MaintenanceService()
    
    func loadMaintenanceEvents(for user: User?) {
        guard let user = user else { return }
        
        isLoading = true
        error = nil
        
        // For demo purposes, we'll load mock data
        loadMockMaintenanceEvents(for: user)
    }
    
    // For demo purposes, load mock maintenance events
    private func loadMockMaintenanceEvents(for user: User) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Generate mock events
            let propertyId = "property-1"
            let currentDate = Date()
            
            // Create events for the current month
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            // Create a range of dates for the current month
            let monthRange = calendar.range(of: .day, in: .month, for: currentDate)!
            let events = (1...monthRange.count).compactMap { day -> Maintenance? in
                // Only create events for some days
                if day % 5 == 0 || day % 7 == 0 {
                    var dateComponents = calendar.dateComponents([.year, .month], from: currentDate)
                    dateComponents.day = day
                    
                    if let date = calendar.date(from: dateComponents) {
                        let randomHour = Int.random(in: 9...17) // Between 9 AM and 5 PM
                        let eventDate = calendar.date(bySettingHour: randomHour, minute: 0, second: 0, of: date)!
                        
                        return Maintenance(
                            id: "maintenance-\(day)",
                            propertyId: propertyId,
                            description: self.randomMaintenanceDescription(),
                            date: Timestamp(date: eventDate),
                            status: self.randomMaintenanceStatus(),
                            notes: day % 3 == 0 ? "Additional notes for this maintenance task." : nil
                        )
                    }
                }
                return nil
            }
            
            self.maintenanceEvents = events
            self.isLoading = false
        }
    }
    
    // Generate random maintenance descriptions for mock data
    private func randomMaintenanceDescription() -> String {
        let descriptions = [
            "Plumber visit to fix leaky faucet",
            "HVAC system inspection",
            "Replace air filters",
            "Pest control service",
            "Landscaping maintenance",
            "Check smoke detectors",
            "Electrical system inspection",
            "Window cleaning service",
            "Carpet cleaning"
        ]
        return descriptions.randomElement() ?? "Maintenance visit"
    }
    
    // Generate random maintenance status for mock data
    private func randomMaintenanceStatus() -> MaintenanceStatus {
        let statuses: [MaintenanceStatus] = [.scheduled, .completed, .cancelled]
        let weights = [0.7, 0.2, 0.1] // 70% scheduled, 20% completed, 10% cancelled
        
        let randomValue = Double.random(in: 0..<1)
        var cumulativeWeight = 0.0
        
        for (index, weight) in weights.enumerated() {
            cumulativeWeight += weight
            if randomValue < cumulativeWeight {
                return statuses[index]
            }
        }
        
        return .scheduled
    }
    
    // Add a new maintenance event
    func addMaintenanceEvent(_ event: Maintenance) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Add the event to the list
            self.maintenanceEvents.append(event)
            
            // Set the selected date to the date of the new event
            self.selectedDate = event.date.dateValue()
            
            self.isLoading = false
        }
    }
    
    // Update maintenance status
    func updateMaintenanceStatus(event: Maintenance, newStatus: MaintenanceStatus) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Find the event and update its status
            if let index = self.maintenanceEvents.firstIndex(where: { $0.id == event.id }) {
                var updatedEvent = self.maintenanceEvents[index]
                updatedEvent.status = newStatus
                self.maintenanceEvents[index] = updatedEvent
            }
            
            self.isLoading = false
        }
    }
    
    // Select an event for editing
    func selectEventForEdit(event: Maintenance) {
        selectedEvent = event
    }
    
    // Update a maintenance event after editing
    func updateMaintenanceEvent(_ updatedEvent: Maintenance) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Find the event and update it
            if let index = self.maintenanceEvents.firstIndex(where: { $0.id == updatedEvent.id }) {
                self.maintenanceEvents[index] = updatedEvent
            }
            
            // Update selected date if the event date changed
            self.selectedDate = updatedEvent.date.dateValue()
            
            self.isLoading = false
        }
    }
    
    // Show delete confirmation
    func showDeleteConfirmation(for event: Maintenance) {
        eventToDelete = event
        showingDeleteAlert = true
    }
    
    // Delete a maintenance event
    func deleteMaintenanceEvent() {
        guard let eventToDelete = eventToDelete else { return }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Remove the event from the list
            self.maintenanceEvents.removeAll { $0.id == eventToDelete.id }
            
            self.isLoading = false
            self.eventToDelete = nil
        }
    }
}

#Preview {
    MaintenanceView()
        .environmentObject(AuthService())
} 