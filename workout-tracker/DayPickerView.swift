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
    @Query(sort: \WorkoutDay.date, order: .reverse) private var workoutDays: [WorkoutDay]
    
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Day",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .onChange(of: selectedDate) { _, newValue in
                    selectedDate = Calendar.current.startOfDay(for: newValue)
                }
                
                Divider()
                
                if let day = existingDay(for: selectedDate) {
                    SessionListView(workoutDay: day)
                } else {
                    ContentUnavailableView(
                        "No workouts logged",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Tap below to start a session on this day")
                    )
                    
                    Button {
                        startNewSession(on: selectedDate)
                    } label: {
                        Label("Start Session", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .navigationTitle("Workout Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
    
    private func existingDay(for date: Date) -> WorkoutDay? {
        let target = Calendar.current.startOfDay(for: date)
        return workoutDays.first { Calendar.current.isDate($0.date, inSameDayAs: target) }
    }
    
    private func startNewSession(on date: Date) {
        let day: WorkoutDay
        if let existing = existingDay(for: date) {
            day = existing
        } else {
            day = WorkoutDay(date: Calendar.current.startOfDay(for: date))
            modelContext.insert(day)
        }
        
        let session = WorkoutSession(startTime: Date())
        day.sessions.append(session)
        try? modelContext.save()
    }
}
