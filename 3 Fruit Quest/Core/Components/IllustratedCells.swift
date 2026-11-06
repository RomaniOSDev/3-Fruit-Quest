//
//  IllustratedCells.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct ArtThumb: View {
    let name: String
    var size: CGFloat = 54

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: AppDepth.softShadow, radius: 6, y: 3)
    }
}

struct IllustratedMetricCell: View {
    let title: String
    let value: String
    let artName: String
    var accent: Color = AppTheme.leaf

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ArtThumb(name: artName, size: 44)
            Text(value)
                .font(AppTheme.metricFont)
                .foregroundStyle(AppTheme.soil)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.bark.opacity(0.72))
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cellBackground(accent: accent))
    }
}

struct IllustratedActivityCell: View {
    let entry: ActivityEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ArtThumb(name: entry.kind.artName, size: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.amount) \(entry.kind.unitLabel)")
                    .font(AppFont.semibold(17))
                    .foregroundStyle(AppTheme.soil)
                Text(entry.kind.title)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.7))
                Text(entry.kind.accentHint)
                    .font(AppFont.medium(11))
                    .foregroundStyle(AppTheme.leaf)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.55))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            GroveIconButton(
                systemName: "trash",
                size: 40,
                fill: AppTheme.dangerSoft,
                action: onDelete
            )
        }
        .padding(14)
        .background(cellBackground(accent: AppTheme.leaf))
    }
}

struct IllustratedQuestCell: View {
    let quest: CareQuest
    let onLog: () -> Void

    @State private var fillPulse = 0
    @State private var showBurst = false
    @State private var sealPop = false
    @State private var lastProgress = -1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    ArtThumb(name: quest.kind.artName, size: 62)
                        .ritualFillPulse(trigger: fillPulse)

                    if showBurst {
                        RitualSparkBurst(accent: quest.isComplete ? AppTheme.moss : AppTheme.apricot)
                            .frame(width: 62, height: 62)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(AppFont.semibold(17))
                        .foregroundStyle(AppTheme.soil)
                    Text(quest.detail)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                if quest.isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.moss)
                        .scaleEffect(sealPop ? 1.2 : 1)
                        .symbolEffect(.bounce, value: sealPop)
                }
            }

            RitualProgressBar(
                progress: quest.fraction,
                tint: quest.isComplete ? AppTheme.moss : AppTheme.leaf,
                isComplete: quest.isComplete
            )

            HStack {
                Text("\(min(quest.progress, quest.target)) / \(quest.target) \(quest.kind.unitLabel)")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.7))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: quest.progress)
                Spacer()
                if !quest.isComplete {
                    GrovePillButton(title: "Log", isSelected: true, action: onLog)
                        .frame(width: 88)
                } else {
                    Text("Complete")
                        .font(AppFont.semibold(12))
                        .foregroundStyle(AppTheme.moss)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppTheme.moss.opacity(0.16)))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(16)
        .background(cellBackground(accent: quest.isComplete ? AppTheme.moss : AppTheme.peach))
        .ritualFillPulse(trigger: fillPulse)
        .onAppear {
            lastProgress = quest.progress
            sealPop = quest.isComplete
        }
        .onChange(of: quest.progress) { _, newValue in
            guard newValue != lastProgress else { return }
            lastProgress = newValue
            fillPulse += 1
            showBurst = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showBurst = false
            }
            if quest.isComplete {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                    sealPop = true
                }
            }
        }
        .onChange(of: quest.isComplete) { _, complete in
            guard complete else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                sealPop = true
            }
            showBurst = true
        }
    }
}

struct IllustratedKindChip: View {
    let kind: ActivityKind
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ArtThumb(name: kind.artName, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.title)
                        .font(AppFont.semibold(14))
                        .foregroundStyle(isSelected ? AppTheme.pulp : AppTheme.soil)
                        .lineLimit(1)
                    Text(kind.accentHint)
                        .font(AppFont.medium(10))
                        .foregroundStyle(isSelected ? AppTheme.pulp.opacity(0.85) : AppTheme.bark.opacity(0.65))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AppTheme.canopy : Color.white.opacity(0.72))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(isSelected ? AppTheme.leaf : Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: AppDepth.softShadow, radius: isSelected ? 8 : 4, y: 3)
        }
        .buttonStyle(GrovePressStyle())
    }
}

struct IllustratedEmptyHint: View {
    let title: String
    let detail: String
    var artName: String = "IconEmptyLog"

    var body: some View {
        VStack(spacing: 14) {
            ArtThumb(name: artName, size: 88)
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.soil)
            Text(detail)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.bark.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(cellBackground(accent: AppTheme.apricot))
    }
}

struct IllustratedSpeciesCell: View {
    let species: FruitSpecies
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(species.artName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 108)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )

                Text(species.displayName)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.soil)
                    .lineLimit(1)

                Text(species.tagline)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 196, alignment: .top)
            .background(cellBackground(accent: species.ripeColor, selected: isSelected))
        }
        .buttonStyle(GrovePressStyle())
    }
}

struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 8) {
            ArtThumb(name: "IconStreak", size: 28)
            Text("\(days) day streak")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.soil)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.72))
                .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1))
        )
    }
}

private func cellBackground(accent: Color, selected: Bool = false) -> some View {
    RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
        .fill(
            LinearGradient(
                colors: [
                    Color.white.opacity(selected ? 0.92 : 0.78),
                    accent.opacity(selected ? 0.22 : 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .stroke(selected ? accent.opacity(0.85) : Color.white.opacity(0.55), lineWidth: selected ? 2 : 1)
        )
        .shadow(color: AppDepth.softShadow, radius: selected ? 14 : 10, y: selected ? 8 : 6)
}
