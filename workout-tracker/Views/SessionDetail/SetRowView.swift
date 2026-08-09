//
//  SetRowView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct SetRowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var unitSettings: UnitSettings
    @Bindable var set: ExerciseSet
    
    // Weight is always stored in lbs on the model; this bridges display <-> storage
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
            
            Text("reps ×")
                .foregroundStyle(.secondary)
            
            TextField("Weight", value: displayWeight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
            
            Text(unitSettings.unit.rawValue)
                .foregroundStyle(.secondary)
        }
        .onChange(of: set.reps) { _, _ in try? modelContext.save() }
    }
}
