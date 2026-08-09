//
//  ContentView.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        DayPickerView()
            .task {
                ExerciseSeedData.seedIfNeeded(context: modelContext)
            }
    }
}
