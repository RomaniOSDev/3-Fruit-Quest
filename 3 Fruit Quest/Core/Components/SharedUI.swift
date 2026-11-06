//
//  SharedUI.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct GroveCard<Content: View>: View {
    let content: Content
    var accent: Color = AppTheme.leaf

    init(accent: Color = AppTheme.leaf, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.pulp.opacity(0.94),
                                accent.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                    )
                    .shadow(color: AppDepth.softShadow, radius: 14, y: 8)
            )
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.soil)
            if let subtitle {
                Text(subtitle)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MetricChip: View {
    let title: String
    let value: String
    let symbolName: String
    var accent: Color = AppTheme.leaf

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbolName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accent)
            Text(value)
                .font(AppTheme.metricFont)
                .foregroundStyle(AppTheme.soil)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.bark.opacity(0.7))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
    }
}

struct SoftProgressBar: View {
    let progress: Double
    var tint: Color = AppTheme.leaf

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.bark.opacity(0.12))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.75)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, geo.size.width * max(0, min(1, progress))))
            }
        }
        .frame(height: 10)
    }
}

struct EmptyHint: View {
    let title: String
    let detail: String
    let symbolName: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.leaf)
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.soil)
            Text(detail)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.bark.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(Color.white.opacity(0.45))
        )
    }
}
