//
//  DaySummaryView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI

struct DaySummaryView: View {
    @EnvironmentObject private var unitSettings: UnitSettings
    
    let date: Date
    let day: WorkoutDay?  // nil when no workouts logged yet for this date
    let isExpanded: Bool
    let onTap: () -> Void
    
    private var muscleGroupVolumes: [(group: MuscleGroup, volume: Double)] {
        guard let day else { return [] }
        return WorkoutCalculations.volumeByMuscleGroup(for: day)
            .map { (group: $0.key, volume: $0.value) }
            .sorted { $0.volume > $1.volume }
    }
    
    private var sessionCount: Int {
        day?.sessions.count ?? 0
    }
    
    private var totalSets: Int {
        guard let day else { return 0 }
        return WorkoutCalculations.totalSets(for: day)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(date, style: .date)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                HStack(spacing: 20) {
                    Label("\(sessionCount) session\(sessionCount == 1 ? "" : "s")", systemImage: "figure.strengthtraining.traditional")
                    Label("\(totalSets) sets", systemImage: "list.number")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.default)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if !muscleGroupVolumes.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(muscleGroupVolumes.prefix(3), id: \.group) { entry in
                            Text("\(entry.group.rawValue): \(Int(unitSettings.unit.convert(fromLbs: entry.volume)))\(unitSettings.unit.rawValue)")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
