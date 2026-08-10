//
//  ExerciseProgressView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    @EnvironmentObject private var unitSettings: UnitSettings
    let exercise: Exercise
    
    @Query(sort: \WorkoutExercise.loggedAt, order: .forward) private var allWorkoutExercises: [WorkoutExercise]
    
    private enum Metric: String, CaseIterable {
        case maxWeight = "Max Weight"
        case volume = "Volume"
    }
    
    @State private var selectedMetric: Metric = .maxWeight
    
    private var history: [WorkoutExercise] {
        allWorkoutExercises.filter { $0.exercise.persistentModelID == exercise.persistentModelID }
    }
    
    private struct DataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    
    private var dataPoints: [DataPoint] {
        history.compactMap { instance in
            switch selectedMetric {
            case .maxWeight:
                guard let maxWeight = instance.sets.map(\.weight).max(), maxWeight > 0 else { return nil }
                return DataPoint(date: instance.loggedAt, value: unitSettings.unit.convert(fromLbs: maxWeight))
            case .volume:
                let volume = WorkoutCalculations.volume(for: instance)
                guard volume > 0 else { return nil }
                return DataPoint(date: instance.loggedAt, value: unitSettings.unit.convert(fromLbs: volume))
            }
        }
    }
    
    private var bestValue: Double? {
        dataPoints.map(\.value).max()
    }
    
    private var mostRecentValue: Double? {
        dataPoints.last?.value
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if dataPoints.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Log a few sessions with this exercise to see your progress over time.")
                    )
                    .padding(.top, 40)
                } else {
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(Metric.allCases, id: \.self) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        if let bestValue {
                            StatBlock(label: "Best", value: bestValue, unit: unitSettings.unit.rawValue)
                        }
                        if let mostRecentValue {
                            StatBlock(label: "Most Recent", value: mostRecentValue, unit: unitSettings.unit.rawValue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Chart(dataPoints) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value(selectedMetric.rawValue, point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)
                        
                        PointMark(
                            x: .value("Date", point.date),
                            y: .value(selectedMetric.rawValue, point.value)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 220)
                    .padding(.horizontal)
                    .chartYAxisLabel(unitSettings.unit.rawValue)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StatBlock: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(Int(value)) \(unit)")
                .font(.title3.bold())
        }
    }
}
