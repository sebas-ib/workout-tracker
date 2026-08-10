//
//  ExerciseSet.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import Foundation
import SwiftData

// A single set: reps + weight
@Model
class ExerciseSet {
    var reps: Int
    var weight: Double
    var order: Int
    var takenToFailure: Bool
    
    init(reps: Int, weight: Double, order: Int, takenToFailure: Bool = false) {
        self.reps = reps
        self.weight = weight
        self.order = order
        self.takenToFailure = takenToFailure
    }
}
