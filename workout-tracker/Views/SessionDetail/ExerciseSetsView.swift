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
    
    @Query(sort: \WorkoutExercise.loggedAt, order: .reverse) private var allWorkoutExercises: [WorkoutExercise]
    
    private var previousWorkoutExercise: WorkoutExercise? {
        allWorkoutExercises.first {
            $0.exercise.persistentModelID == workoutExercise.exercise.persistentModelID &&
            $0.persistentModelID != workoutExercise.persistentModelID &&
            $0.loggedAt < workoutExercise.loggedAt
        }
    }
    
    private func previousSet(forOrder order: Int) -> ExerciseSet? {
        previousWorkoutExercise?.sets.sorted(by: { $0.order < $1.order })
            .first { $0.order == order }
    }
    
    var body: some View {
        ForEach(workoutExercise.sets.sorted(by: { $0.order < $1.order })) { set in
            SetRowView(
                set: set,
                focusedField: focusedField,
                previousSet: previousSet(forOrder: set.order)
            )
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
        workoutExercise.sets.removeAll { deletedSet in
            offsets.contains { sorted[$0].persistentModelID == deletedSet.persistentModelID }
        }
        
        renumberSets()
        
        try? modelContext.save()
    }
    
    /// Re-assigns order values 1, 2, 3... sequentially based on current position,
    /// so deleting set 4 out of 5 shifts what was set 5 down to become set 4.
    private func renumberSets() {
        let sorted = workoutExercise.sets.sorted(by: { $0.order < $1.order })
        for (index, set) in sorted.enumerated() {
            set.order = index + 1
        }
    }
}
