//
//  ScreenHeroImage.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

enum ScreenArt: String {
    case onboarding = "ScreenOnboarding"
    case stem = "ScreenStem"
    case companion = "ScreenCompanion"
    case log = "ScreenLog"
    case seal = "ScreenSeal"
    case care = "ScreenCare"
    case radar = "ScreenRadar"
    case pulse = "ScreenPulse"
}

struct ScreenHeroImage: View {
    let art: ScreenArt
    var height: CGFloat = 160

    var body: some View {
        Image(art.rawValue)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: AppDepth.softShadow, radius: 12, y: 6)
            .accessibilityHidden(true)
    }
}
