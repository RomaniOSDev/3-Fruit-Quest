//
//  AppTheme.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

enum AppFont {
    static let family = "Fredoka"

    static func regular(_ size: CGFloat) -> Font {
        .custom("Fredoka-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Fredoka-Medium", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Fredoka-SemiBold", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("Fredoka-Bold", size: size)
    }
}

enum AppTheme {
    /// Dusk canopy — deeper, evening-seal palette (not the old soft morning sticker look).
    static let canopy = Color(red: 0.08, green: 0.20, blue: 0.16)
    static let leaf = Color(red: 0.28, green: 0.48, blue: 0.34)
    static let moss = Color(red: 0.36, green: 0.55, blue: 0.32)
    static let peach = Color(red: 0.90, green: 0.55, blue: 0.34)
    static let apricot = Color(red: 0.93, green: 0.68, blue: 0.28)
    static let blossom = Color(red: 0.88, green: 0.72, blue: 0.58)
    static let skyMist = Color(red: 0.82, green: 0.88, blue: 0.84)
    static let groveFog = Color(red: 0.62, green: 0.72, blue: 0.64)
    static let soil = Color(red: 0.12, green: 0.10, blue: 0.08)
    static let bark = Color(red: 0.32, green: 0.24, blue: 0.18)
    static let pulp = Color(red: 0.97, green: 0.94, blue: 0.88)
    static let wilt = Color(red: 0.50, green: 0.42, blue: 0.30)
    static let dangerSoft = Color(red: 0.74, green: 0.34, blue: 0.28)
    static let dusk = Color(red: 0.55, green: 0.38, blue: 0.22)

    static let titleFont = AppFont.bold(34)
    static let headlineFont = AppFont.semibold(22)
    static let bodyFont = AppFont.regular(16)
    static let captionFont = AppFont.medium(12)
    static let metricFont = AppFont.bold(26)
    static let buttonFont = AppFont.semibold(17)
    static let tabFont = AppFont.semibold(11)

    static let cardRadius: CGFloat = 20
    static let controlRadius: CGFloat = 14
    static let tabBarClearance: CGFloat = 112
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 18
    static let contentTop: CGFloat = 16
    static let contentBottom: CGFloat = 24
}

enum AppDepth {
    static let softShadow = Color.black.opacity(0.12)
    static let liftShadow = Color.black.opacity(0.20)
}
