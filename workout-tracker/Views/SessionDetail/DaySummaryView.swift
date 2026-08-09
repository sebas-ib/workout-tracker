//
//  DaySummaryView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI

struct DaySummaryView: View {
    @EnvironmentObject private var unitSettings: UnitSettings
    let day: WorkoutDay
    
    private var muscleGroupVolumes: [(group: MuscleGroup, volume: Double)] {
        WorkoutCalculations.volumeByMuscleGroup(for: day)
            .map { (group: $0.key, volume: $0.value) }
            .sorted { $0.volume > $1.volume }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.date, style: .date)
                .font(.headline)
            
            HStack(spacing: 20) {
                Label("\(day.sessions.count) session\(day.sessions.count == 1 ? "" : "s")", systemImage: "figure.strengthtraining.traditional")
                Label("\(WorkoutCalculations.totalSets(for: day)) sets", systemImage: "list.number")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            if !muscleGroupVolumes.isEmpty {
                HStack(spacing: 8) {
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
        .padding(.vertical, 20)
    }
}
