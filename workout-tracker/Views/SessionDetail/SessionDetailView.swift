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
            
            if session.exercises.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "dumbbell.fill",
                        description: Text("Tap 'Add Exercise' below to start tracking your movements.")
                    )
                    .listRowBackground(Color.clear)
                }
            } else {
                ForEach(session.exercises) { workoutExercise in
                    Section {
                        ExerciseSetsView(workoutExercise: workoutExercise, focusedField: $focusedField)
                    } header: {
                        Text(workoutExercise.exercise.name)
                            .font(.headline)
                            .textCase(nil)
                    }
                }
                .onDelete(perform: deleteExercises)
            }
            
            Section {
                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } footer: {
                Spacer()
                    .frame(height: 60)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(session.name ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView { selectedExercise in
                addExercise(selectedExercise)
            }
        }
        .highPriorityGesture(
            TapGesture().onEnded {
                focusedField = nil
            },
            including: focusedField != nil ? .all : .none // Only active when keyboard is open
        )
    }
        
    private func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise)
        
        session.exercises.append(workoutExercise)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save newly added exercise: \(error.localizedDescription)")
        }
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            let exerciseToDelete = session.exercises[index]
            modelContext.delete(exerciseToDelete)
        }
        session.exercises.remove(atOffsets: offsets)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save deletion context updates: \(error.localizedDescription)")
        }
    }
}
