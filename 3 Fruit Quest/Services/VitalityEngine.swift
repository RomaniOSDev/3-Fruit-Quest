//
//  VitalityEngine.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import Foundation

enum VitalityEngine {
    static func vitality(
        steps: Int,
        walkMinutes: Int,
        water: Int,
        stretchMinutes: Int,
        dailyStepGoal: Int
    ) -> Double {
        let goal = max(1000, dailyStepGoal)
        let stepScore = min(1.0, Double(steps) / Double(goal)) * 58
        let walkScore = min(1.0, Double(walkMinutes) / 40.0) * 22
        let waterScore = min(1.0, Double(water) / 8.0) * 10
        let stretchScore = min(1.0, Double(stretchMinutes) / 20.0) * 10
        return min(100, max(8, stepScore + walkScore + waterScore + stretchScore))
    }

    static func aggregate(entries: [ActivityEntry], dayKey: String, dailyStepGoal: Int) -> DaySnapshot {
        let dayEntries = entries.filter { $0.dayKey == dayKey }
        var steps = 0
        var walkMinutes = 0
        var water = 0
        var stretchMinutes = 0

        for entry in dayEntries {
            switch entry.kind {
            case .steps: steps += entry.amount
            case .walkMinutes: walkMinutes += entry.amount
            case .water: water += entry.amount
            case .stretch: stretchMinutes += entry.amount
            }
        }

        let value = vitality(
            steps: steps,
            walkMinutes: walkMinutes,
            water: water,
            stretchMinutes: stretchMinutes,
            dailyStepGoal: dailyStepGoal
        )

        return DaySnapshot(
            dayKey: dayKey,
            steps: steps,
            walkMinutes: walkMinutes,
            water: water,
            stretchMinutes: stretchMinutes,
            vitality: value
        )
    }

    static func bloomProgress(vitality: Double) -> Double {
        min(1, max(0, (vitality - 20) / 80))
    }

    static func wiltFactor(vitality: Double) -> Double {
        min(1, max(0, (45 - vitality) / 45))
    }
}
