//
//  workout_trackerTests.swift
//  workout-trackerTests
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//

import Testing
import SwiftData
@testable import workout_tracker

struct WorkoutTrackerTests {

    @Test @MainActor func seedingPopulatesExercises() throws {
        let schema = Schema([Exercise.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        ExerciseSeedData.seedIfNeeded(context: context)

        let descriptor = FetchDescriptor<Exercise>()
        let count = try context.fetchCount(descriptor)

        #expect(count == ExerciseSeedData.starterExercises.count)
    }

    @Test @MainActor func seedingDoesNotDuplicateOnSecondCall() throws {
        let schema = Schema([Exercise.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        ExerciseSeedData.seedIfNeeded(context: context)
        ExerciseSeedData.seedIfNeeded(context: context) // call twice

        let descriptor = FetchDescriptor<Exercise>()
        let count = try context.fetchCount(descriptor)

        #expect(count == ExerciseSeedData.starterExercises.count) // still same count, no dupes
    }
}
