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

    let workoutDay: WorkoutDay

    @State private var sessionPendingDeletion: WorkoutSession?
    @State private var saveError: Error?

    private var sortedSessions: [WorkoutSession] {
        workoutDay.sessions.sorted {
            $0.startTime < $1.startTime
        }
    }

    var body: some View {
        Section {
            ForEach(sortedSessions) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.name ?? "Session")
                            .font(.headline)

                        Text(session.startTime, style: .time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    Button {
                        sessionPendingDeletion = session
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }

            Button {
                addSession()
            } label: {
                Label("Add Another Session", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
        } header: {
            Text("Sessions")
        }
        .alert(
            "Delete \(sessionPendingDeletion?.name ?? "Session")?",
            isPresented: deletionAlertBinding
        ) {
            Button("Cancel", role: .cancel) {
                sessionPendingDeletion = nil
            }

            Button("Delete", role: .destructive) {
                deletePendingSession()
            }
        } message: {
            Text(
                "This will permanently remove this session and all logged exercises and sets within it."
            )
        }
        .alert(
            "Couldn't Save Changes",
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

    private var deletionAlertBinding: Binding<Bool> {
        Binding(
            get: {
                sessionPendingDeletion != nil
            },
            set: { isPresented in
                if !isPresented {
                    sessionPendingDeletion = nil
                }
            }
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

    private func addSession() {
        guard workoutDay.date <= Calendar.current.startOfDay(for: Date()) else { return }
        
        let session = WorkoutSession(startTime: Date())
        workoutDay.sessions.append(session)

        saveChanges()
    }

    private func deletePendingSession() {
        guard let session = sessionPendingDeletion else {
            return
        }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            workoutDay.sessions.removeAll {
                $0.persistentModelID == session.persistentModelID
            }

            modelContext.delete(session)
            sessionPendingDeletion = nil
        }

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
