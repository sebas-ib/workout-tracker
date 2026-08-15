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
    @EnvironmentObject private var unitSettings: UnitSettings

    let workoutDay: WorkoutDay
    let onSessionCreated: (WorkoutSession) -> Void

    @State private var sessionPendingDeletion: WorkoutSession?
    @State private var showingNewSessionSheet = false
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.name ?? "Session")
                            .font(.headline)

                        Text(session.startTime, style: .time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        let volumes = muscleGroupVolumes(for: session)
                        if !volumes.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(volumes.prefix(3), id: \.group) { entry in
                                    Text("\(entry.group.rawValue): \(Int(unitSettings.unit.convert(fromLbs: entry.volume)))\(unitSettings.unit.rawValue)")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(Theme.accent)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(Theme.accent.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 2)
                        }
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
                showingNewSessionSheet = true
            } label: {
                Label("Add Another Session", systemImage: "plus")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.bordered)
            .tint(Theme.accent)
            .padding(.horizontal)
            .sheet(isPresented: $showingNewSessionSheet) {
                NewSessionView(targetDate: workoutDay.date) { newSession in
                    workoutDay.sessions.append(newSession)
                    saveChanges()
                    onSessionCreated(newSession)
                }
                .tint(Theme.accent)
            }
        } header: {
            Text("Sessions")
                .font(Theme.sectionHeader())
                .foregroundStyle(.secondary)
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
    
    private func muscleGroupVolumes(for session: WorkoutSession) -> [(group: MuscleGroup, volume: Double)] {
        WorkoutCalculations.volumeByMuscleGroup(for: session)
            .map { (group: $0.key, volume: $0.value) }
            .sorted { $0.volume > $1.volume }
    }

    private var deletionAlertBinding: Binding<Bool> {
        Binding(
            get: { sessionPendingDeletion != nil },
            set: { isPresented in
                if !isPresented { sessionPendingDeletion = nil }
            }
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

    private func deletePendingSession() {
        guard let session = sessionPendingDeletion else { return }

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
