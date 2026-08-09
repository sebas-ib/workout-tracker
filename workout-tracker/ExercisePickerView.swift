//
//  ExercisePickerView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    
    @State private var searchText = ""
    
    let onSelect: (Exercise) -> Void
    
    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var exactMatchExists: Bool {
        exercises.contains { $0.name.localizedCaseInsensitiveCompare(searchText) == .orderedSame }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !searchText.isEmpty && !exactMatchExists {
                    Button {
                        addCustomExercise()
                    } label: {
                        Label("Add \"\(searchText)\" as new exercise", systemImage: "plus.circle.fill")
                    }
                }
                
                ForEach(filteredExercises) { exercise in
                    Button {
                        onSelect(exercise)
                        dismiss()
                    } label: {
                        HStack {
                            Text(exercise.name)
                                .foregroundStyle(.primary)
                            if exercise.isCustom {
                                Spacer()
                                Text("Custom")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addCustomExercise() {
        let newExercise = Exercise(name: searchText, isCustom: true)
        modelContext.insert(newExercise)
        try? modelContext.save()
        onSelect(newExercise)
        dismiss()
    }
}
