//
//  ExerciseSeedData.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//


import Foundation
import SwiftData

enum ExerciseSeedData {
    static let starterExercises: [String] = [
        // Chest
        "Bench Press",
        "Incline Bench Press",
        "Dumbbell Press",
        "Push-Up",
        "Chest Fly",

        // Back
        "Deadlift",
        "Pull-Up",
        "Lat Pulldown",
        "Bent-Over Row",
        "Seated Cable Row",

        // Legs
        "Squat",
        "Leg Press",
        "Hack Squat",
        "Leg Curl",
        "Leg Extension",
        "Calf Raise",

        // Shoulders
        "Overhead Press",
        "Lateral Raise",
        "Lateral Raise Machine",
        "Front Raise",
        "Face Pull",

        // Arms
        "Bicep Curl",
        "Hammer Curl",
        "Bicep Curl Machine",
        "Tricep Pushdown",
        "Overhead Tricep Extension",
        "Tricep Dip",
        "Skull Crusher",

        // Core
        "Plank",
        "Crunch",
        "Russian Twist",
        "Hanging Leg Raise",
        "Abdominal Crunch Machine"
    ]
}

extension ExerciseSeedData {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return } // already seeded, skip
        
        for name in starterExercises {
            let exercise = Exercise(name: name, isCustom: false)
            context.insert(exercise)
        }
        
        try? context.save()
    }
}
