//
//  PetMood.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

enum PetMood: String, Codable, CaseIterable {
    case wilted
    case drowsy
    case steady
    case blooming
    case radiant

    var title: String {
        switch self {
        case .wilted: return "Wilting"
        case .drowsy: return "Drowsy"
        case .steady: return "Steady"
        case .blooming: return "Blooming"
        case .radiant: return "Radiant"
        }
    }

    var message: String {
        switch self {
        case .wilted: return "Needs a walk to perk back up."
        case .drowsy: return "A short stroll would brighten things."
        case .steady: return "Holding shape. Keep the rhythm going."
        case .blooming: return "Color is returning. Feels alive."
        case .radiant: return "Fully awake. Your pace is feeding the glow."
        }
    }

    var symbolName: String {
        switch self {
        case .wilted: return "leaf.arrow.triangle.circlepath"
        case .drowsy: return "moon.zzz.fill"
        case .steady: return "leaf.fill"
        case .blooming: return "sun.max.fill"
        case .radiant: return "sparkles"
        }
    }

    static func from(vitality: Double) -> PetMood {
        switch vitality {
        case ..<25: return .wilted
        case ..<45: return .drowsy
        case ..<65: return .steady
        case ..<85: return .blooming
        default: return .radiant
        }
    }
}
