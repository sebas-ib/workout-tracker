//
//  NewSessionView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var allSessions: [WorkoutSession]

    @State private var sessionName: String = ""

    let onCreate: (WorkoutSession) -> Void

    // Only show past sessions that actually have exercises, so the template list is useful
    private var pastSessions: [WorkoutSession] {
        allSessions.filter { !$0.exercises.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Session Name (Optional)") {
                    TextField("e.g. Push Day", text: $sessionName)
                }

                Section {
                    Button {
                        createBlankSession()
                    } label: {
                        Label("Start Blank Session", systemImage: "plus.circle.fill")
                    }
                }

                if !pastSessions.isEmpty {
                    Section("Use a Previous Session as a Template") {
                        ForEach(pastSessions.prefix(20)) { session in
                            Button {
                                createSessionFromTemplate(session)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.name ?? "Session")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(session.startTime, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(session.exercises.map { $0.exercise.name }.joined(separator: ", "))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func createBlankSession() {
        let session = WorkoutSession(startTime: Date(), name: sessionName.isEmpty ? nil : sessionName)
        onCreate(session)
        dismiss()
    }

    private func createSessionFromTemplate(_ template: WorkoutSession) {
        let session = WorkoutSession(
            startTime: Date(),
            name: sessionName.isEmpty ? template.name : sessionName
        )

        for templateExercise in template.exercises {
            let newWorkoutExercise = WorkoutExercise(exercise: templateExercise.exercise)
            let sortedTemplateSets = templateExercise.sets.sorted(by: { $0.order < $1.order })

            for templateSet in sortedTemplateSets {
                // Leave reps/weight blank — the "last time" numbers show automatically
                // as ghost hints once this exercise renders (see ExerciseSetsView changes below)
                newWorkoutExercise.sets.append(ExerciseSet(reps: 0, weight: 0, order: templateSet.order))
            }

            session.exercises.append(newWorkoutExercise)
        }

        onCreate(session)
        dismiss()
    }
}
