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
    static let canopy = Color(red: 0.12, green: 0.30, blue: 0.23)
    static let leaf = Color(red: 0.24, green: 0.55, blue: 0.43)
    static let moss = Color(red: 0.42, green: 0.63, blue: 0.36)
    static let peach = Color(red: 0.94, green: 0.63, blue: 0.48)
    static let apricot = Color(red: 0.96, green: 0.74, blue: 0.42)
    static let blossom = Color(red: 0.95, green: 0.78, blue: 0.72)
    static let skyMist = Color(red: 0.91, green: 0.95, blue: 0.92)
    static let groveFog = Color(red: 0.78, green: 0.88, blue: 0.82)
    static let soil = Color(red: 0.17, green: 0.14, blue: 0.11)
    static let bark = Color(red: 0.35, green: 0.28, blue: 0.22)
    static let pulp = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let wilt = Color(red: 0.55, green: 0.48, blue: 0.32)
    static let dangerSoft = Color(red: 0.78, green: 0.38, blue: 0.32)

    static let titleFont = AppFont.bold(34)
    static let headlineFont = AppFont.semibold(22)
    static let bodyFont = AppFont.regular(16)
    static let captionFont = AppFont.medium(12)
    static let metricFont = AppFont.bold(26)
    static let buttonFont = AppFont.semibold(17)
    static let tabFont = AppFont.semibold(11)

    static let cardRadius: CGFloat = 22
    static let controlRadius: CGFloat = 16
    static let tabBarClearance: CGFloat = 112
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 18
    static let contentTop: CGFloat = 16
    static let contentBottom: CGFloat = 24
}

enum AppDepth {
    static let softShadow = Color.black.opacity(0.10)
    static let liftShadow = Color.black.opacity(0.16)
}
