import Foundation
import SwiftData

enum ExerciseSeedData {
    static let starterExercises: [(name: String, primary: MuscleGroup, secondary: MuscleGroup?)] = [
        // Chest
        ("Bench Press", .chest, .arms),
        ("Incline Bench Press", .chest, .shoulders),
        ("Dumbbell Press", .chest, .arms),
        ("Push-Up", .chest, .arms),
        ("Chest Fly", .chest, nil),

        // Back
        ("Deadlift", .back, .legs),
        ("Pull-Up", .back, .arms),
        ("Lat Pulldown", .back, .arms),
        ("Bent-Over Row", .back, .arms),
        ("Seated Cable Row", .back, .arms),

        // Legs
        ("Squat", .legs, .core),
        ("Leg Press", .legs, nil),
        ("Lunges", .legs, nil),
        ("Leg Curl", .legs, nil),
        ("Leg Extension", .legs, nil),
        ("Calf Raise", .legs, nil),

        // Shoulders
        ("Overhead Press", .shoulders, .arms),
        ("Lateral Raise", .shoulders, nil),
        ("Front Raise", .shoulders, nil),
        ("Face Pull", .shoulders, .back),

        // Arms
        ("Bicep Curl", .arms, nil),
        ("Hammer Curl", .arms, nil),
        ("Tricep Pushdown", .arms, nil),
        ("Tricep Dip", .arms, .chest),
        ("Skull Crusher", .arms, nil),

        // Core
        ("Plank", .core, nil),
        ("Crunch", .core, nil),
        ("Russian Twist", .core, nil),
        ("Hanging Leg Raise", .core, nil)
    ]
}

extension ExerciseSeedData {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else {
            migrateUntaggedExercisesIfNeeded(context: context)
            return
        }
        
        for entry in starterExercises {
            let exercise = Exercise(
                name: entry.name,
                isCustom: false,
                muscleGroup: entry.primary,
                secondaryMuscleGroup: entry.secondary
            )
            context.insert(exercise)
        }
        
        try? context.save()
    }
    
    @MainActor
    static func migrateUntaggedExercisesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>()
        guard let allExercises = try? context.fetch(descriptor) else { return }
        
        let nameToEntry = Dictionary(uniqueKeysWithValues: starterExercises.map { ($0.name, $0) })
        var didUpdate = false
        
        for exercise in allExercises {
            if exercise.muscleGroupRawValue.isEmpty, let match = nameToEntry[exercise.name] {
                exercise.muscleGroup = match.primary
                exercise.secondaryMuscleGroup = match.secondary
                didUpdate = true
            }
        }
        
        if didUpdate {
            try? context.save()
        }
    }
}

