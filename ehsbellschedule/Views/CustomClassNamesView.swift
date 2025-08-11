import SwiftUI
import Combine

struct CustomClassNamesView: View {
    @ObservedObject private var preferences = UserPreferences.shared
    @Environment(\.dismiss) private var dismiss
    @State private var editingClassInfo: [Int: ClassInfo] = [:]
    @State private var hasChanges = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allPeriods, id: \.number) { period in
                    periodRow(for: period)
                }
            }
            .onAppear {
                // Always initialize on appear to ensure fresh data
                initializeEditingInfo()
            }
            .navigationTitle("Custom Class Names")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!hasChanges)
                }
            }
        }
        .onReceive(preferences.$showPeriod0.combineLatest(preferences.$showPeriod7)) { _, _ in
            // Reinitialize when period visibility settings change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                initializeEditingInfo()
            }
        }
    }
    
    private var allPeriods: [Period] {
        let schedule = Schedule.mondaySchedule
        return schedule.filteredPeriods(
            showPeriod0: preferences.showPeriod0,
            showPeriod7: preferences.showPeriod7
        ).filter { $0.number != 99 } // Exclude ACCESS period (99) from editing
    }
    
    private func periodRow(for period: Period) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with period info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(period.displayName)
                        .font(Constants.Fonts.headline)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text(TimeFormatter.shared.formatTimeRange(
                        start: period.startDate,
                        end: period.endDate,
                        use24Hour: preferences.use24HourFormat
                    ))
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                // Period number badge
                Text("\(period.number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Constants.Colors.primaryGreen)
                    )
            }
            
            // Input fields
            VStack(alignment: .leading, spacing: 12) {
                // Class name field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Class Name")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    TextField(period.defaultName, text: classNameBinding(for: period.number))
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                }
                
                // Teacher field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Teacher")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    TextField("Enter teacher name", text: teacherBinding(for: period.number))
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                }
                
                // Room field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Room Number")
                        .font(Constants.Fonts.caption)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    TextField("Enter room number", text: roomBinding(for: period.number))
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                }
            }
            
            // Reset button - show if any field has content
            if let classInfo = editingClassInfo[period.number], !classInfo.isEmpty {
                Button(action: {
                    editingClassInfo[period.number] = ClassInfo(name: "")
                    hasChanges = true
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left")
                            .font(.caption)
                        Text("Reset to default")
                            .font(Constants.Fonts.caption)
                    }
                    .foregroundColor(Constants.Colors.primaryGreen)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func classNameBinding(for periodNumber: Int) -> Binding<String> {
        Binding(
            get: {
                let name = editingClassInfo[periodNumber]?.name ?? ""
                print("📖 Getting class name for period \(periodNumber): '\(name)'")
                return name
            },
            set: { newValue in
                let currentInfo = editingClassInfo[periodNumber] ?? ClassInfo(name: "")
                editingClassInfo[periodNumber] = ClassInfo(
                    name: newValue,
                    teacher: currentInfo.teacher,
                    room: currentInfo.room
                )
                hasChanges = true
            }
        )
    }
    
    private func teacherBinding(for periodNumber: Int) -> Binding<String> {
        Binding(
            get: {
                editingClassInfo[periodNumber]?.teacher ?? ""
            },
            set: { newValue in
                let currentInfo = editingClassInfo[periodNumber] ?? ClassInfo(name: "")
                editingClassInfo[periodNumber] = ClassInfo(
                    name: currentInfo.name,
                    teacher: newValue,
                    room: currentInfo.room
                )
                hasChanges = true
            }
        )
    }
    
    private func roomBinding(for periodNumber: Int) -> Binding<String> {
        Binding(
            get: {
                editingClassInfo[periodNumber]?.room ?? ""
            },
            set: { newValue in
                let currentInfo = editingClassInfo[periodNumber] ?? ClassInfo(name: "")
                editingClassInfo[periodNumber] = ClassInfo(
                    name: currentInfo.name,
                    teacher: currentInfo.teacher,
                    room: newValue
                )
                hasChanges = true
            }
        )
    }
    
    private func initializeEditingInfo() {
        // Clear existing data first to ensure fresh state
        editingClassInfo.removeAll()
        
        for period in allPeriods {
            let classInfo = preferences.getClassInfo(for: period)
            editingClassInfo[period.number] = classInfo
        }
    }
    
    private func saveChanges() {
        for (periodNumber, classInfo) in editingClassInfo {
            preferences.setClassInfo(classInfo, for: periodNumber)
            
            // Clear the old customClassNames entry to avoid confusion
            if preferences.customClassNames[periodNumber] != nil {
                preferences.customClassNames[periodNumber] = nil
            }
        }
        
        // Force a UI update by triggering objectWillChange
        preferences.objectWillChange.send()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    CustomClassNamesView()
}