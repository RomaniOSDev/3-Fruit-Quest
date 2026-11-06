//
//  ActivityEntry.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import Foundation

enum ActivityKind: String, Codable, CaseIterable, Identifiable {
    case steps
    case walkMinutes
    case water
    case stretch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .steps: return "Steps"
        case .walkMinutes: return "Walk minutes"
        case .water: return "Water glasses"
        case .stretch: return "Stretch minutes"
        }
    }

    var unitLabel: String {
        switch self {
        case .steps: return "steps"
        case .walkMinutes: return "min"
        case .water: return "glasses"
        case .stretch: return "min"
        }
    }

    var symbolName: String {
        switch self {
        case .steps: return "figure.walk"
        case .walkMinutes: return "timer"
        case .water: return "drop.fill"
        case .stretch: return "figure.flexibility"
        }
    }

    var artName: String {
        switch self {
        case .steps: return "IconSteps"
        case .walkMinutes: return "IconWalk"
        case .water: return "IconWater"
        case .stretch: return "IconStretch"
        }
    }

    var accentHint: String {
        switch self {
        case .steps: return "Glow fuel"
        case .walkMinutes: return "Orchard path"
        case .water: return "Root sip"
        case .stretch: return "Stem limber"
        }
    }

    var suggestedAmounts: [Int] {
        switch self {
        case .steps: return [1000, 2500, 5000, 8000]
        case .walkMinutes: return [10, 20, 30, 45]
        case .water: return [1, 2, 3, 4]
        case .stretch: return [5, 10, 15, 20]
        }
    }
}

struct ActivityEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: ActivityKind
    let amount: Int
    let note: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        kind: ActivityKind,
        amount: Int,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.amount = max(0, amount)
        self.note = note
        self.createdAt = createdAt
    }

    var dayKey: String {
        ActivityEntry.dayFormatter.string(from: createdAt)
    }

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
