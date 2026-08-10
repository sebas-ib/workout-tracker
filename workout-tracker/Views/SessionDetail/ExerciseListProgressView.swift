//
//  ExerciseListProgressView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct ExerciseListProgressView: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    
    private var groupedExercises: [MuscleGroup: [Exercise]] {
        Dictionary(grouping: exercises, by: { $0.muscleGroup })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(MuscleGroup.allCases, id: \.self) { group in
                    if let groupExercises = groupedExercises[group], !groupExercises.isEmpty {
                        Section(group.rawValue) {
                            ForEach(groupExercises) { exercise in
                                NavigationLink {
                                    ExerciseProgressView(exercise: exercise)
                                } label: {
                                    Text(exercise.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }
}
