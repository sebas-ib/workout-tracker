//
//  SetRowView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

enum SetField: Hashable {
    case reps(PersistentIdentifier)
    case weight(PersistentIdentifier)
}

struct SetRowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var unitSettings: UnitSettings
    @Bindable var set: ExerciseSet
    var focusedField: FocusState<SetField?>.Binding
    var previousSet: ExerciseSet?
    
    private var displayWeight: Binding<Double> {
        Binding(
            get: { unitSettings.unit.convert(fromLbs: set.weight) },
            set: { newValue in
                set.weight = unitSettings.unit.convertToLbs(newValue)
                try? modelContext.save()
            }
        )
    }
    
    private var previousHint: String? {
        guard let previousSet else { return nil }
        let displayPreviousWeight = unitSettings.unit.convert(fromLbs: previousSet.weight)
        return "Last: \(previousSet.reps) × \(String(format: "%.0f", displayPreviousWeight)) \(unitSettings.unit.rawValue)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Set \(set.order)")
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                
                TextField("Reps", value: $set.reps, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .focused(focusedField, equals: .reps(set.persistentModelID))
                
                Text("reps ×")
                    .foregroundStyle(.secondary)
                
                TextField("Weight", value: displayWeight, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                    .focused(focusedField, equals: .weight(set.persistentModelID))
                
                Text(unitSettings.unit.rawValue)
                    .foregroundStyle(.secondary)
            }
            
            if let previousHint {
                Text(previousHint)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 50)
            }
        }
        .onChange(of: set.reps) { _, _ in try? modelContext.save() }
    }
}
