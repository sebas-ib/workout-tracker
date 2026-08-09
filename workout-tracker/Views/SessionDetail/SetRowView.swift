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
    
    private var displayWeight: Binding<Double> {
        Binding(
            get: { unitSettings.unit.convert(fromLbs: set.weight) },
            set: { newValue in
                set.weight = unitSettings.unit.convertToLbs(newValue)
                try? modelContext.save()
            }
        )
    }
    
    var body: some View {
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
        .onChange(of: set.reps) { _, _ in try? modelContext.save() }
    }
}
