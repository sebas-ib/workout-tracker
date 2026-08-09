//
//  SessionSummaryView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject private var unitSettings: UnitSettings
    let session: WorkoutSession
    
    private var displayVolume: Double {
        unitSettings.unit.convert(fromLbs: WorkoutCalculations.totalVolume(for: session))
    }
    
    var body: some View {
        HStack(spacing: 20) {
            SummaryStat(
                label: "Volume",
                value: String(format: "%.0f", displayVolume),
                unit: unitSettings.unit.rawValue
            )
            SummaryStat(
                label: "Sets",
                value: "\(WorkoutCalculations.totalSets(for: session))",
                unit: ""
            )
            SummaryStat(
                label: "Reps",
                value: "\(WorkoutCalculations.totalReps(for: session))",
                unit: ""
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SummaryStat: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack {
            Text(value + (unit.isEmpty ? "" : " \(unit)"))
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
