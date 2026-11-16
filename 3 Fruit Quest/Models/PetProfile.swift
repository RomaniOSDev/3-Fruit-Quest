//
//  PetProfile.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

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

enum SlipKind: String, Codable, CaseIterable, Identifiable {
    case weather
    case workCrush
    case fatigue
    case mood
    case travel
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weather: return "Weather"
        case .workCrush: return "Work crush"
        case .fatigue: return "Fatigue"
        case .mood: return "Mood dip"
        case .travel: return "Travel"
        case .other: return "Other"
        }
    }

    var detail: String {
        switch self {
        case .weather: return "Rain, heat, or ice pulled you indoors"
        case .workCrush: return "Meetings and deadlines ate the walk"
        case .fatigue: return "Body asked for rest instead of pace"
        case .mood: return "Energy dipped before movement started"
        case .travel: return "Routes and bags broke the rhythm"
        case .other: return "Something else bent the day"
        }
    }

    var symbolName: String {
        switch self {
        case .weather: return "cloud.rain.fill"
        case .workCrush: return "briefcase.fill"
        case .fatigue: return "moon.zzz.fill"
        case .mood: return "heart.slash.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum CarryIntention: String, Codable, CaseIterable, Identifiable {
    case morningLoop
    case eveningStroll
    case hydrate
    case stretchReset
    case deskBreakWalk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morningLoop: return "Morning loop"
        case .eveningStroll: return "Evening stroll"
        case .hydrate: return "Hydrate early"
        case .stretchReset: return "Stretch reset"
        case .deskBreakWalk: return "Desk-break walk"
        }
    }

    var detail: String {
        switch self {
        case .morningLoop: return "Open the day with a short outdoor loop"
        case .eveningStroll: return "Close with an unhurried walk"
        case .hydrate: return "Front-load water before noon"
        case .stretchReset: return "Loosen the stem after long sitting"
        case .deskBreakWalk: return "Park a 10-minute walk between blocks"
        }
    }

    var artName: String {
        switch self {
        case .morningLoop: return "IconWalk"
        case .eveningStroll: return "IconWalk"
        case .hydrate: return "IconWater"
        case .stretchReset: return "IconStretch"
        case .deskBreakWalk: return "IconSteps"
        }
    }

    var accent: Color {
        switch self {
        case .morningLoop: return AppTheme.apricot
        case .eveningStroll: return AppTheme.dusk
        case .hydrate: return AppTheme.leaf
        case .stretchReset: return AppTheme.peach
        case .deskBreakWalk: return AppTheme.moss
        }
    }
}

struct DaySeal: Identifiable, Codable, Equatable {
    var id: String { dayKey }
    let dayKey: String
    var carryIntentions: [CarryIntention]
    var residueNote: String
    var residueTag: SlipKind?
    var sealedAt: Date
}

struct SlipEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: SlipKind
    let note: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        kind: SlipKind,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.note = note
        self.createdAt = createdAt
    }

    var dayKey: String {
        ActivityEntry.dayFormatter.string(from: createdAt)
    }
}

struct MorningBrief: Equatable {
    let fromDayKey: String
    let carryIntentions: [CarryIntention]
    let residueNote: String
    let suggestedQuietHour: Int?
    let hasSeal: Bool

    var quietWindowLabel: String {
        guard let hour = suggestedQuietHour else {
            return "No quiet window yet — log a few walks first"
        }
        let end = (hour + 1) % 24
        return String(format: "Suggested quiet walk · %02d:00–%02d:00", hour, end)
    }
}
