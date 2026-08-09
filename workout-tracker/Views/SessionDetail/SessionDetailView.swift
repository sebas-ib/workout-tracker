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
    @FocusState private var focusedField: SetField?
    
    var body: some View {
        List {
            Section {
                SessionSummaryView(session: session)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            ForEach(session.exercises) { workoutExercise in
                Section {
                    ExerciseSetsView(workoutExercise: workoutExercise, focusedField: $focusedField)
                } header: {
                    Text(workoutExercise.exercise.name)
                }
            }
            .onDelete(perform: deleteExercises)
            
            Section {
                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(session.name ?? "Session")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedField = nil
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
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
