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

                if let day = selectedDay, !day.sessions.isEmpty {
                    DaySummaryView(day: day)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top)
                                    .combined(with: .opacity),
                                removal: .move(edge: .top)
                                    .combined(with: .opacity)
                            )
                        )

                    SessionListView(workoutDay: day)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom)
                                    .combined(with: .opacity),
                                removal: .move(edge: .bottom)
                                    .combined(with: .opacity)
                            )
                        )
                } else {
                    emptyWorkoutSection
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.95)
                                    .combined(with: .opacity),
                                removal: .scale(scale: 0.95)
                                    .combined(with: .opacity)
                            )
                        )
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

    private var emptyWorkoutSection: some View {
        Section {
            VStack(spacing: 20) {
                ContentUnavailableView(
                    "No Workouts Logged",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text(
                        "Start a session to begin tracking your workout."
                    )
                )

                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        startNewSession()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Start Session")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 220)
            .padding(.vertical, 20)
        }
        .transition(
            .asymmetric(
                insertion: .opacity,
                removal: .scale(scale: 0.95).combined(with: .opacity)
            )
        )
    }

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
