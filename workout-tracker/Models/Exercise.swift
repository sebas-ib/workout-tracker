//
//  Exercise.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import Foundation
import SwiftData

@Model
class Exercise {
    var name: String
    var isCustom: Bool
    var muscleGroupRawValue: String          // primary — counts toward volume
    var secondaryMuscleGroupRawValue: String?  // optional — display/reference only
    
    var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRawValue) ?? .other }
        set { muscleGroupRawValue = newValue.rawValue }
    }
    
    var secondaryMuscleGroup: MuscleGroup? {
        get { secondaryMuscleGroupRawValue.flatMap { MuscleGroup(rawValue: $0) } }
        set { secondaryMuscleGroupRawValue = newValue?.rawValue }
    }
    
    init(name: String, isCustom: Bool = false, muscleGroup: MuscleGroup = .other, secondaryMuscleGroup: MuscleGroup? = nil) {
        self.name = name
        self.isCustom = isCustom
        self.muscleGroupRawValue = muscleGroup.rawValue
        self.secondaryMuscleGroupRawValue = secondaryMuscleGroup?.rawValue
    }
}
