//
//  SessionListView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var workoutDay: WorkoutDay
    
    var body: some View {
        List {
            Section {
                DaySummaryView(day: workoutDay)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            ForEach(workoutDay.sessions.sorted(by: { $0.startTime < $1.startTime })) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    VStack(alignment: .leading) {
                        Text(session.name ?? "Session")
                            .font(.headline)
                        Text(session.startTime, style: .time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteSessions)
            
            Button {
                addSession()
            } label: {
                Label("Add Another Session", systemImage: "plus")
            }
        }
    }
    
    private func addSession() {
        let session = WorkoutSession(startTime: Date())
        workoutDay.sessions.append(session)
        try? modelContext.save()
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        let sorted = workoutDay.sessions.sorted(by: { $0.startTime < $1.startTime })
        for index in offsets {
            modelContext.delete(sorted[index])
        }
        try? modelContext.save()
    }
}
