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

    let targetDate: Date
    let onCreate: (WorkoutSession) -> Void

    @State private var sessionName: String = ""
    @State private var sessionStartTime: Date

    init(targetDate: Date, onCreate: @escaping (WorkoutSession) -> Void) {
        self.targetDate = targetDate
        self.onCreate = onCreate
        _sessionStartTime = State(initialValue: Self.defaultStartTime(for: targetDate))
    }

    private var pastSessions: [WorkoutSession] {
        allSessions.filter { !$0.exercises.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Session Name (Optional)") {
                    TextField("e.g. Push Day", text: $sessionName)
                }

                Section("Date & Time") {
                    DatePicker(
                        "Date",
                        selection: $sessionStartTime,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    DatePicker(
                        "Time",
                        selection: $sessionStartTime,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section {
                    Button {
                        createBlankSession()
                    } label: {
                        Label("Start Session", systemImage: "plus.circle.fill")
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

    /// Combines the target date with the current clock time as a sensible starting default.
    private static func defaultStartTime(for targetDate: Date) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: targetDate
        ) ?? targetDate
    }

    private func createBlankSession() {
        let session = WorkoutSession(
            startTime: sessionStartTime,
            name: sessionName.isEmpty ? nil : sessionName
        )
        onCreate(session)
        dismiss()
    }

    private func createSessionFromTemplate(_ template: WorkoutSession) {
        let session = WorkoutSession(
            startTime: sessionStartTime,
            name: sessionName.isEmpty ? template.name : sessionName
        )

        for templateExercise in template.exercises {
            let newWorkoutExercise = WorkoutExercise(exercise: templateExercise.exercise, loggedAt: sessionStartTime)
            let sortedTemplateSets = templateExercise.sets.sorted(by: { $0.order < $1.order })

            for templateSet in sortedTemplateSets {
                newWorkoutExercise.sets.append(ExerciseSet(reps: 0, weight: 0, order: templateSet.order))
            }

            session.exercises.append(newWorkoutExercise)
        }

        onCreate(session)
        dismiss()
    }
}
