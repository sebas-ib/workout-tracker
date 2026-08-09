//
//  DayPickerView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//

import SwiftUI
import SwiftData

struct DayPickerView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \WorkoutDay.date, order: .reverse)
    private var workoutDays: [WorkoutDay]

    @State private var selectedDate = Calendar.current.startOfDay(
        for: Date()
    )

    @State private var saveError: Error?

    private var selectedDay: WorkoutDay? {
        workoutDays.first {
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: selectedDate
            )
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Consistency Graph

                Section {
                    ConsistencyGraphView()
                        .frame(maxWidth: .infinity)
                        .listRowInsets(
                            EdgeInsets(
                                top: 8,
                                leading: 0,
                                bottom: 8,
                                trailing: 0
                            )
                        )
                        .listRowBackground(Color.clear)
                }

                // MARK: - Date Picker

                Section {
                    DatePicker(
                        "Select Day",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .onChange(of: selectedDate) { _, newDate in
                        selectedDate = Calendar.current.startOfDay(
                            for: newDate
                        )
                    }
                }

                // MARK: - Workout

                if let day = selectedDay {
                    DaySummaryView(day: day)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                    if !day.sessions.isEmpty {
                        SessionListView(workoutDay: day)
                    } else {
                        emptyWorkoutSection
                    }
                } else {
                    emptyWorkoutSection
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Workout Tracker")
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
            .alert(
                "Couldn't Save Workout",
                isPresented: saveErrorBinding
            ) {
                Button("OK", role: .cancel) {
                    saveError = nil
                }
            } message: {
                Text(
                    saveError?.localizedDescription
                    ?? "An unknown error occurred while saving your workout."
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyWorkoutSection: some View {
        Section {
            ContentUnavailableView(
                "No Workouts Logged",
                systemImage: "figure.strengthtraining.traditional",
                description: Text(
                    "Start a session to begin tracking your workout."
                )
            )
            .frame(maxWidth: .infinity)

            Button {
                startNewSession()
            } label: {
                Label(
                    "Start Session",
                    systemImage: "plus.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Save Error

    private var saveErrorBinding: Binding<Bool> {
        Binding(
            get: {
                saveError != nil
            },
            set: { isPresented in
                if !isPresented {
                    saveError = nil
                }
            }
        )
    }

    // MARK: - Actions

    private func startNewSession() {
        let day: WorkoutDay

        if let existingDay = selectedDay {
            day = existingDay
        } else {
            day = WorkoutDay(date: selectedDate)
            modelContext.insert(day)
        }

        let session = WorkoutSession(startTime: Date())
        day.sessions.append(session)

        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            saveError = error
        }
    }
}
