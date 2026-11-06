//
//  FruitSpecies.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

enum FruitSpecies: String, Codable, CaseIterable, Identifiable {
    case avocado
    case peach
    case lemon
    case plum
    case pear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .avocado: return "Avocado"
        case .peach: return "Peach"
        case .lemon: return "Lemon"
        case .plum: return "Plum"
        case .pear: return "Pear"
        }
    }

    var tagline: String {
        switch self {
        case .avocado: return "Calm, creamy, and stubbornly loyal"
        case .peach: return "Soft glow with a sunny temper"
        case .lemon: return "Zesty spark that loves bright days"
        case .plum: return "Quiet depth with velvet energy"
        case .pear: return "Gentle shape, steady growth"
        }
    }

    var ripeColor: Color {
        switch self {
        case .avocado: return Color(red: 0.45, green: 0.62, blue: 0.28)
        case .peach: return Color(red: 0.96, green: 0.62, blue: 0.45)
        case .lemon: return Color(red: 0.96, green: 0.84, blue: 0.28)
        case .plum: return Color(red: 0.55, green: 0.28, blue: 0.48)
        case .pear: return Color(red: 0.72, green: 0.78, blue: 0.32)
        }
    }

    var fleshColor: Color {
        switch self {
        case .avocado: return Color(red: 0.86, green: 0.90, blue: 0.55)
        case .peach: return Color(red: 0.98, green: 0.86, blue: 0.72)
        case .lemon: return Color(red: 0.99, green: 0.95, blue: 0.72)
        case .plum: return Color(red: 0.86, green: 0.62, blue: 0.78)
        case .pear: return Color(red: 0.93, green: 0.92, blue: 0.70)
        }
    }

    var wiltColor: Color {
        switch self {
        case .avocado: return Color(red: 0.48, green: 0.46, blue: 0.28)
        case .peach: return Color(red: 0.62, green: 0.48, blue: 0.34)
        case .lemon: return Color(red: 0.62, green: 0.58, blue: 0.28)
        case .plum: return Color(red: 0.40, green: 0.30, blue: 0.36)
        case .pear: return Color(red: 0.52, green: 0.50, blue: 0.30)
        }
    }

    var leafAccent: Color {
        switch self {
        case .avocado: return Color(red: 0.22, green: 0.48, blue: 0.28)
        case .peach: return Color(red: 0.30, green: 0.55, blue: 0.30)
        case .lemon: return Color(red: 0.28, green: 0.52, blue: 0.26)
        case .plum: return Color(red: 0.26, green: 0.46, blue: 0.30)
        case .pear: return Color(red: 0.34, green: 0.56, blue: 0.28)
        }
    }

    var artName: String {
        switch self {
        case .avocado: return "FruitAvocado"
        case .peach: return "FruitPeach"
        case .lemon: return "FruitLemon"
        case .plum: return "FruitPlum"
        case .pear: return "FruitPear"
        }
    }
}
