//
//  WorkoutDay.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import Foundation
import SwiftData

// A calendar day can have multiple sessions (AM/PM/etc.)
@Model
class WorkoutDay {
    var date: Date
    @Relationship(deleteRule: .cascade) var sessions: [WorkoutSession]
    
    init(date: Date) {
        self.date = date
        self.sessions = []
    }
}

// A single session within a day (e.g. "Morning Push Day")
@Model
class WorkoutSession {
    var startTime: Date
    var name: String? // optional label, e.g. "Morning", "Leg Day"
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]
    
    init(startTime: Date, name: String? = nil) {
        self.startTime = startTime
        self.name = name
        self.exercises = []
    }
}

// A logged exercise instance within a session, linked to the library
@Model
class WorkoutExercise {
    var exercise: Exercise // reference to the library entry
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self.sets = []
    }
}

// A single set: reps + weight
@Model
class ExerciseSet {
    var reps: Int
    var weight: Double
    var order: Int
    
    init(reps: Int, weight: Double, order: Int) {
        self.reps = reps
        self.weight = weight
        self.order = order
    }
}

// The reusable exercise library — preset + user-added
@Model
class Exercise {
    var name: String
    var isCustom: Bool // true if user-added, false if from your preset list
    
    init(name: String, isCustom: Bool = false) {
        self.name = name
        self.isCustom = isCustom
    }
}
