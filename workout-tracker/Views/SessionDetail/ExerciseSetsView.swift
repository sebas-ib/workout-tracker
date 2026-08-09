//
//  ExerciseSetsView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct ExerciseSetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var workoutExercise: WorkoutExercise
    var focusedField: FocusState<SetField?>.Binding
    
    var body: some View {
        ForEach(workoutExercise.sets.sorted(by: { $0.order < $1.order })) { set in
            SetRowView(set: set, focusedField: focusedField)
        }
        .onDelete(perform: deleteSets)
        
        Button {
            addSet()
        } label: {
            Label("Add Set", systemImage: "plus.circle")
        }
        .font(.subheadline)
    }
    
    private func addSet() {
        let nextOrder = (workoutExercise.sets.map(\.order).max() ?? 0) + 1
        let newSet = ExerciseSet(reps: 0, weight: 0, order: nextOrder)
        workoutExercise.sets.append(newSet)
        try? modelContext.save()
    }
    
    private func deleteSets(at offsets: IndexSet) {
        let sorted = workoutExercise.sets.sorted(by: { $0.order < $1.order })
        for index in offsets {
            modelContext.delete(sorted[index])
        }
        try? modelContext.save()
    }
}
