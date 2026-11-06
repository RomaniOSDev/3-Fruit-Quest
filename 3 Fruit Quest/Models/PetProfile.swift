//
//  PetProfile.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import Foundation

struct PetProfile: Codable, Equatable {
    var name: String
    var species: FruitSpecies
    var dailyStepGoal: Int
    var createdAt: Date
    var onboardingCompleted: Bool

    static let blank = PetProfile(
        name: "",
        species: .avocado,
        dailyStepGoal: 8000,
        createdAt: Date(),
        onboardingCompleted: false
    )
}

struct DaySnapshot: Identifiable, Codable, Equatable {
    var id: String { dayKey }
    let dayKey: String
    var steps: Int
    var walkMinutes: Int
    var water: Int
    var stretchMinutes: Int
    var vitality: Double

    static func empty(dayKey: String) -> DaySnapshot {
        DaySnapshot(
            dayKey: dayKey,
            steps: 0,
            walkMinutes: 0,
            water: 0,
            stretchMinutes: 0,
            vitality: 18
        )
    }
}

struct CareQuest: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let symbolName: String
    let target: Int
    let progress: Int
    let kind: ActivityKind

    var isComplete: Bool { progress >= target }

    var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(progress) / Double(target))
    }
}
