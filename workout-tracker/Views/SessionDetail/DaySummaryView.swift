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
    
    private var displayVolume: Double {
        unitSettings.unit.convert(fromLbs: WorkoutCalculations.totalVolume(for: day))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.date, style: .date)
                .font(.headline)
            
            HStack(spacing: 20) {
                Label("\(day.sessions.count) session\(day.sessions.count == 1 ? "" : "s")", systemImage: "figure.strengthtraining.traditional")
                Label(String(format: "%.0f \(unitSettings.unit.rawValue)", displayVolume), systemImage: "scalemass")
                Label("\(WorkoutCalculations.totalSets(for: day)) sets", systemImage: "list.number")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
