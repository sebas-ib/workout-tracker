//
//  SessionDetailView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var session: WorkoutSession
    
    @State private var showingExercisePicker = false
    
    var body: some View {
        List {
            ForEach(session.exercises) { workoutExercise in
                Section {
                    ExerciseSetsView(workoutExercise: workoutExercise)
                } header: {
                    Text(workoutExercise.exercise.name)
                }
            }
            .onDelete(perform: deleteExercises)
        }
        .navigationTitle(session.name ?? "Session")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView { selectedExercise in
                addExercise(selectedExercise)
            }
        }
    }
    
    private func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise)
        session.exercises.append(workoutExercise)
        try? modelContext.save()
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(session.exercises[index])
        }
        try? modelContext.save()
    }
}
