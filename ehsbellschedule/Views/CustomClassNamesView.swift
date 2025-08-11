import SwiftUI

struct CustomClassNamesView: View {
    @StateObject private var preferences = UserPreferences()
    @Environment(\.dismiss) private var dismiss
    @State private var editingClassNames: [Int: String] = [:]
    @State private var hasChanges = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allPeriods, id: \.number) { period in
                    periodRow(for: period)
                }
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
        .onAppear {
            initializeEditingNames()
        }
    }
    
    private var allPeriods: [Period] {
        let schedule = Schedule.mondaySchedule
        return schedule.periods
    }
    
    private func periodRow(for period: Period) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Period \(period.number)")
                    .font(Constants.Fonts.headline)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Text(TimeFormatter.shared.formatTimeRange(
                    start: period.startDate,
                    end: period.endDate,
                    use24Hour: preferences.use24HourFormat
                ))
                .font(Constants.Fonts.caption)
                .foregroundColor(Constants.Colors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Class Name")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                TextField(period.defaultName, text: binding(for: period.number))
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: editingClassNames[period.number] ?? "") { _ in
                        hasChanges = true
                    }
            }
            
            if !(editingClassNames[period.number]?.isEmpty ?? true) {
                Button(action: {
                    editingClassNames[period.number] = ""
                    hasChanges = true
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left")
                            .font(.caption)
                        Text("Reset to default")
                            .font(Constants.Fonts.caption)
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func binding(for periodNumber: Int) -> Binding<String> {
        Binding(
            get: {
                editingClassNames[periodNumber] ?? ""
            },
            set: { newValue in
                editingClassNames[periodNumber] = newValue
            }
        )
    }
    
    private func initializeEditingNames() {
        for period in allPeriods {
            editingClassNames[period.number] = preferences.customClassNames[period.number] ?? ""
        }
    }
    
    private func saveChanges() {
        for (periodNumber, className) in editingClassNames {
            if className.isEmpty {
                preferences.customClassNames[periodNumber] = nil
            } else {
                preferences.customClassNames[periodNumber] = className
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    CustomClassNamesView()
}