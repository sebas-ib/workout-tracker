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

    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var saveError: Error?
    @State private var showingNewSessionSheet = false
    @State private var newlyCreatedSession: WorkoutSession?
    @State private var datePickerExpanded = false

    private var selectedDay: WorkoutDay? {
        workoutDays.first {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DaySummaryView(
                        date: selectedDate,
                        day: selectedDay,
                        isExpanded: datePickerExpanded
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            datePickerExpanded.toggle()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        Color(uiColor: UIColor { traitCollection in
                            traitCollection.userInterfaceStyle == .dark
                                ? UIColor.secondarySystemBackground
                                : UIColor.tertiarySystemBackground
                        })
                    )
                    .padding()
                    
                    if datePickerExpanded {
                        DatePicker(
                            "Select Day",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .onChange(of: selectedDate) { _, newValue in
                            selectedDate = Calendar.current.startOfDay(for: newValue)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                } header: {
                    Text("Date Picker")
                }
                
                if let day = selectedDay, !day.sessions.isEmpty {
                    SessionListView(workoutDay: day) { newSession in
                        scheduleNavigation(to: newSession)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                } else {
                    emptyWorkoutSection
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
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
            .sheet(isPresented: $showingNewSessionSheet) {
                NewSessionView(targetDate: selectedDate) { newSession in
                    attachNewSession(newSession)
                    scheduleNavigation(to: newSession)
                }
            }
            .navigationDestination(item: $newlyCreatedSession) { session in
                SessionDetailView(session: session)
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
            VStack(spacing: 20) {
                ContentUnavailableView(
                    "No Workouts Logged",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("Start a session to begin tracking your workout.")
                )

                Button {
                    showingNewSessionSheet = true
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
        } header: {
            Text("Sessions")
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
            get: { saveError != nil },
            set: { isPresented in
                if !isPresented { saveError = nil }
            }
        )
    }
    
    private func attachNewSession(_ session: WorkoutSession) {
        let day: WorkoutDay
        if let existing = selectedDay {
            day = existing
        } else {
            day = WorkoutDay(date: selectedDate)
            modelContext.insert(day)
        }
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
    
    private func scheduleNavigation(to session: WorkoutSession) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            newlyCreatedSession = session
        }
    }
}
