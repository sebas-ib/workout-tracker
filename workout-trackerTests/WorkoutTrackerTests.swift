//
//  workout_trackerTests.swift
//  workout-trackerTests
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import Testing
import SwiftData
import Foundation
@testable import workout_tracker

// MARK: - Test Helper

@MainActor
func makeTestContext() throws -> ModelContext {
    let schema = Schema([
        WorkoutDay.self,
        WorkoutSession.self,
        WorkoutExercise.self,
        ExerciseSet.self,
        Exercise.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [config])
    return ModelContext(container)
}

// MARK: - Exercise Seeding Tests

@Suite("Exercise Seeding")
struct ExerciseSeedingTests {

    @Test @MainActor func seedingPopulatesExercises() throws {
        let context = try makeTestContext()
        ExerciseSeedData.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<Exercise>())
        #expect(count == ExerciseSeedData.starterExercises.count)
    }

    @Test @MainActor func seedingDoesNotDuplicateOnSecondCall() throws {
        let context = try makeTestContext()
        ExerciseSeedData.seedIfNeeded(context: context)
        ExerciseSeedData.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<Exercise>())
        #expect(count == ExerciseSeedData.starterExercises.count)
    }

    @Test @MainActor func seededExercisesAreNotMarkedCustom() throws {
        let context = try makeTestContext()
        ExerciseSeedData.seedIfNeeded(context: context)

        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.allSatisfy { $0.isCustom == false })
    }

    @Test @MainActor func seedingSkipsWhenExercisesAlreadyExist() throws {
        let context = try makeTestContext()
        // Manually insert one custom exercise first
        let manual = Exercise(name: "Manual Entry", isCustom: true)
        context.insert(manual)
        try context.save()

        ExerciseSeedData.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<Exercise>())
        #expect(count == 1) // seeding should NOT have run since count > 0
    }
}

// MARK: - Model Relationship Tests

@Suite("Model Relationships")
struct ModelRelationshipTests {

    @Test @MainActor func workoutDayCanHaveMultipleSessions() throws {
        let context = try makeTestContext()
        let day = WorkoutDay(date: Date())
        let morning = WorkoutSession(startTime: Date(), name: "Morning")
        let evening = WorkoutSession(startTime: Date(), name: "Evening")

        day.sessions.append(morning)
        day.sessions.append(evening)
        context.insert(day)
        try context.save()

        #expect(day.sessions.count == 2)
    }

    @Test @MainActor func sessionCanHaveMultipleExercises() throws {
        let context = try makeTestContext()
        let session = WorkoutSession(startTime: Date())
        let benchExercise = Exercise(name: "Bench Press")
        let squatExercise = Exercise(name: "Squat")

        session.exercises.append(WorkoutExercise(exercise: benchExercise))
        session.exercises.append(WorkoutExercise(exercise: squatExercise))
        context.insert(session)
        try context.save()

        #expect(session.exercises.count == 2)
    }

    @Test @MainActor func workoutExerciseCanHaveMultipleSets() throws {
        let context = try makeTestContext()
        let exercise = Exercise(name: "Deadlift")
        let workoutExercise = WorkoutExercise(exercise: exercise)

        workoutExercise.sets.append(ExerciseSet(reps: 5, weight: 135, order: 1))
        workoutExercise.sets.append(ExerciseSet(reps: 5, weight: 145, order: 2))
        workoutExercise.sets.append(ExerciseSet(reps: 3, weight: 155, order: 3))

        context.insert(workoutExercise)
        try context.save()

        #expect(workoutExercise.sets.count == 3)
    }

    @Test @MainActor func deletingWorkoutDayCascadesToSessions() throws {
        let context = try makeTestContext()
        let day = WorkoutDay(date: Date())
        let session = WorkoutSession(startTime: Date())
        day.sessions.append(session)
        context.insert(day)
        try context.save()

        let sessionCountBefore = try context.fetchCount(FetchDescriptor<WorkoutSession>())
        #expect(sessionCountBefore == 1)

        context.delete(day)
        try context.save()

        let sessionCountAfter = try context.fetchCount(FetchDescriptor<WorkoutSession>())
        #expect(sessionCountAfter == 0)
    }

    @Test @MainActor func deletingSessionCascadesToExercisesAndSets() throws {
        let context = try makeTestContext()
        let session = WorkoutSession(startTime: Date())
        let exercise = Exercise(name: "Squat")
        let workoutExercise = WorkoutExercise(exercise: exercise)
        workoutExercise.sets.append(ExerciseSet(reps: 5, weight: 135, order: 1))
        session.exercises.append(workoutExercise)

        context.insert(session)
        try context.save()

        context.delete(session)
        try context.save()

        let exerciseCount = try context.fetchCount(FetchDescriptor<WorkoutExercise>())
        let setCount = try context.fetchCount(FetchDescriptor<ExerciseSet>())
        #expect(exerciseCount == 0)
        #expect(setCount == 0)
    }

    @Test @MainActor func deletingExerciseFromLibraryDoesNotDeleteWorkoutExercise() throws {
        // Exercise (library) should NOT cascade-delete WorkoutExercise (logged instance),
        // since WorkoutExercise only references it, rather than owning it.
        let context = try makeTestContext()
        let exercise = Exercise(name: "Overhead Press")
        let workoutExercise = WorkoutExercise(exercise: exercise)
        context.insert(exercise)
        context.insert(workoutExercise)
        try context.save()

        context.delete(exercise)

        // This should either throw, or the WorkoutExercise should still exist depending on your
        // delete rule config. This test documents current behavior — adjust once you decide policy.
        let workoutExerciseCount = try context.fetchCount(FetchDescriptor<WorkoutExercise>())
        #expect(workoutExerciseCount == 1)
    }
}

// MARK: - Set Ordering Tests

@Suite("Set Ordering")
struct SetOrderingTests {

    @Test @MainActor func setsPreserveInsertionOrderWhenSortedByOrder() throws {
        let context = try makeTestContext()
        let exercise = Exercise(name: "Bicep Curl")
        let workoutExercise = WorkoutExercise(exercise: exercise)

        workoutExercise.sets.append(ExerciseSet(reps: 10, weight: 20, order: 1))
        workoutExercise.sets.append(ExerciseSet(reps: 8, weight: 25, order: 2))
        workoutExercise.sets.append(ExerciseSet(reps: 6, weight: 30, order: 3))

        context.insert(workoutExercise)
        try context.save()

        let sorted = workoutExercise.sets.sorted(by: { $0.order < $1.order })
        #expect(sorted.map(\.reps) == [10, 8, 6])
        #expect(sorted.map(\.weight) == [20, 25, 30])
    }

    @Test @MainActor func nextSetOrderIncrementsFromMax() throws {
        let exercise = Exercise(name: "Lat Pulldown")
        let workoutExercise = WorkoutExercise(exercise: exercise)
        workoutExercise.sets.append(ExerciseSet(reps: 10, weight: 50, order: 1))
        workoutExercise.sets.append(ExerciseSet(reps: 10, weight: 50, order: 2))

        let nextOrder = (workoutExercise.sets.map(\.order).max() ?? 0) + 1
        #expect(nextOrder == 3)
    }

    @Test @MainActor func nextSetOrderStartsAtOneWhenEmpty() throws {
        let exercise = Exercise(name: "Leg Press")
        let workoutExercise = WorkoutExercise(exercise: exercise)

        let nextOrder = (workoutExercise.sets.map(\.order).max() ?? 0) + 1
        #expect(nextOrder == 1)
    }
}

// MARK: - Unit Conversion Tests

@Suite("Weight Unit Conversion")
struct WeightUnitConversionTests {

    @Test func lbsToLbsIsIdentity() {
        let result = WeightUnit.lbs.convert(fromLbs: 100)
        #expect(result == 100)
    }

    @Test func lbsToKgConvertsCorrectly() {
        let result = WeightUnit.kg.convert(fromLbs: 100)
        #expect(abs(result - 45.3592) < 0.001)
    }

    @Test func kgToLbsRoundTripsCorrectly() {
        let originalLbs = 135.0
        let asKg = WeightUnit.kg.convert(fromLbs: originalLbs)
        let backToLbs = WeightUnit.kg.convertToLbs(asKg)
        #expect(abs(backToLbs - originalLbs) < 0.001)
    }

    @Test func zeroWeightConvertsToZeroInAnyUnit() {
        #expect(WeightUnit.lbs.convert(fromLbs: 0) == 0)
        #expect(WeightUnit.kg.convert(fromLbs: 0) == 0)
    }

    @Test(arguments: [45.0, 100.0, 225.0, 315.0])
    func commonBarbellWeightsConvertWithoutCrashing(weight: Double) {
        let kg = WeightUnit.kg.convert(fromLbs: weight)
        let backToLbs = WeightUnit.kg.convertToLbs(kg)
        #expect(abs(backToLbs - weight) < 0.01)
    }
}

// MARK: - Exercise Library Tests

@Suite("Exercise Library")
struct ExerciseLibraryTests {

    @Test @MainActor func customExerciseIsMarkedCorrectly() throws {
        let context = try makeTestContext()
        let custom = Exercise(name: "My Custom Move", isCustom: true)
        context.insert(custom)
        try context.save()

        #expect(custom.isCustom == true)
    }

    @Test @MainActor func exerciseSearchIsCaseInsensitive() throws {
        let context = try makeTestContext()
        ExerciseSeedData.seedIfNeeded(context: context)

        let allExercises = try context.fetch(FetchDescriptor<Exercise>())
        let matches = allExercises.filter {
            $0.name.localizedCaseInsensitiveContains("bench")
        }

        #expect(matches.contains { $0.name == "Bench Press" })
    }

    @Test @MainActor func noDuplicateExerciseNamesInSeedData() {
        let names = ExerciseSeedData.starterExercises
        let uniqueNames = Set(names)
        #expect(names.count == uniqueNames.count)
    }
}

// MARK: - Workout Calculations Tests

@Suite("Workout Calculations")
struct WorkoutCalculationsTests {

    @Test @MainActor func volumeCalculatesCorrectlyForSingleExercise() throws {
        let exercise = Exercise(name: "Bench Press")
        let workoutExercise = WorkoutExercise(exercise: exercise)
        workoutExercise.sets.append(ExerciseSet(reps: 10, weight: 100, order: 1)) // 1000
        workoutExercise.sets.append(ExerciseSet(reps: 8, weight: 105, order: 2))  // 840

        let volume = WorkoutCalculations.volume(for: workoutExercise)
        #expect(volume == 1840)
    }

    @Test @MainActor func totalVolumeSumsAcrossExercises() throws {
        let session = WorkoutSession(startTime: Date())
        
        let bench = WorkoutExercise(exercise: Exercise(name: "Bench"))
        bench.sets.append(ExerciseSet(reps: 10, weight: 100, order: 1)) // 1000
        
        let squat = WorkoutExercise(exercise: Exercise(name: "Squat"))
        squat.sets.append(ExerciseSet(reps: 5, weight: 200, order: 1)) // 1000
        
        session.exercises = [bench, squat]

        #expect(WorkoutCalculations.totalVolume(for: session) == 2000)
    }

    @Test @MainActor func totalSetsCountsAcrossExercises() throws {
        let session = WorkoutSession(startTime: Date())
        
        let bench = WorkoutExercise(exercise: Exercise(name: "Bench"))
        bench.sets = [
            ExerciseSet(reps: 10, weight: 100, order: 1),
            ExerciseSet(reps: 8, weight: 105, order: 2)
        ]
        session.exercises = [bench]

        #expect(WorkoutCalculations.totalSets(for: session) == 2)
    }

    @Test @MainActor func totalRepsSumsAcrossSets() throws {
        let session = WorkoutSession(startTime: Date())
        let bench = WorkoutExercise(exercise: Exercise(name: "Bench"))
        bench.sets = [
            ExerciseSet(reps: 10, weight: 100, order: 1),
            ExerciseSet(reps: 8, weight: 105, order: 2)
        ]
        session.exercises = [bench]

        #expect(WorkoutCalculations.totalReps(for: session) == 18)
    }

    @Test @MainActor func dayLevelTotalsAggregateAcrossSessions() throws {
        let day = WorkoutDay(date: Date())
        
        let morning = WorkoutSession(startTime: Date())
        let benchMorning = WorkoutExercise(exercise: Exercise(name: "Bench"))
        benchMorning.sets.append(ExerciseSet(reps: 10, weight: 100, order: 1)) // 1000
        morning.exercises = [benchMorning]
        
        let evening = WorkoutSession(startTime: Date())
        let squatEvening = WorkoutExercise(exercise: Exercise(name: "Squat"))
        squatEvening.sets.append(ExerciseSet(reps: 5, weight: 200, order: 1)) // 1000
        evening.exercises = [squatEvening]
        
        day.sessions = [morning, evening]

        #expect(WorkoutCalculations.totalVolume(for: day) == 2000)
        #expect(WorkoutCalculations.totalSets(for: day) == 2)
    }

    @Test @MainActor func emptySessionHasZeroTotals() throws {
        let session = WorkoutSession(startTime: Date())
        
        #expect(WorkoutCalculations.totalVolume(for: session) == 0)
        #expect(WorkoutCalculations.totalSets(for: session) == 0)
        #expect(WorkoutCalculations.totalReps(for: session) == 0)
    }

    @Test @MainActor func maxWeightFindsHeaviestSetAcrossExercises() throws {
        let session = WorkoutSession(startTime: Date())
        let bench = WorkoutExercise(exercise: Exercise(name: "Bench"))
        bench.sets = [
            ExerciseSet(reps: 10, weight: 100, order: 1),
            ExerciseSet(reps: 5, weight: 135, order: 2)
        ]
        session.exercises = [bench]

        #expect(WorkoutCalculations.maxWeight(for: session) == 135)
    }
}
