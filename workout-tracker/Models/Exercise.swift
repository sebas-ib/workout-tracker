//
//  Exercise.swift
//  workout-tracker
//
//  Created by Sebastian Ibarra-Perez on 8/9/26.
//
import Foundation
import SwiftData

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
