//
//  InsightsView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var store: PetStore
    @State private var slipNote = ""
    @State private var selectedSlip: SlipKind = .fatigue

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        SectionHeader(
                            title: "Slip radar",
                            subtitle: "Tag why movement slipped. Patterns shape your quiet-walk window."
                        )

                        ScreenHeroImage(art: .radar, height: 140)
                        quietWindowCard
                        slipComposer
                        slipChart
                        weeklyStats
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppTheme.contentTop)
                    .padding(.bottom, AppTheme.tabBarClearance)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
        }
        .transparentScreenChrome()
    }

    private var quietWindowCard: some View {
        GroveCard(accent: AppTheme.apricot) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested quiet walk")
                    .font(AppFont.semibold(17))
                    .foregroundStyle(AppTheme.soil)
                if let hour = store.suggestedQuietHour() {
                    Text(String(format: "%02d:00–%02d:00 · from your ledger timing", hour, (hour + 1) % 24))
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.8))
                } else {
                    Text("Log a few walks in Ledger to unlock a quiet window.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.75))
                }
            }
        }
    }

    private var slipComposer: some View {
        GroveCard(accent: AppTheme.dusk) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(
                    title: "Tag a slip",
                    subtitle: "Not a streak shamer — a map of what pulled you off the path."
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SlipKind.allCases) { kind in
                            GrovePillButton(
                                title: kind.title,
                                isSelected: selectedSlip == kind
                            ) {
                                selectedSlip = kind
                            }
                        }
                    }
                }

                Text(selectedSlip.detail)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.7))

                TextField("Optional note", text: $slipNote)
                    .font(AppTheme.bodyFont)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.72))
                    )

                GroveButton(title: "Save slip tag", style: .primary) {
                    store.addSlip(kind: selectedSlip, note: slipNote)
                    slipNote = ""
                }
            }
        }
    }

    private var slipChart: some View {
        GroveCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("14-day slip map")
                    .font(AppFont.semibold(17))
                    .foregroundStyle(AppTheme.soil)

                ForEach(store.slipRadar, id: \.kind) { row in
                    HStack(spacing: 10) {
                        Image(systemName: row.kind.symbolName)
                            .foregroundStyle(AppTheme.dusk)
                            .frame(width: 22)
                        Text(row.kind.title)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.soil)
                            .frame(width: 88, alignment: .leading)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(AppTheme.bark.opacity(0.12))
                                Capsule()
                                    .fill(AppTheme.peach)
                                    .frame(width: max(6, geo.size.width * barFraction(row.count)))
                            }
                        }
                        .frame(height: 10)
                        Text("\(row.count)")
                            .font(AppFont.semibold(13))
                            .foregroundStyle(AppTheme.canopy)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
    }

    private var weeklyStats: some View {
        let days = store.recentDays
        let totalSteps = days.reduce(0) { $0 + $1.steps }
        let sealedDays = days.filter { day in store.seals.contains { $0.dayKey == day.dayKey } }.count
        let avgVitality = days.isEmpty ? 0 : days.reduce(0.0) { $0 + $1.vitality } / Double(days.count)

        return HStack(spacing: 10) {
            IllustratedMetricCell(
                title: "7-day steps",
                value: compact(totalSteps),
                artName: ActivityKind.steps.artName
            )
            IllustratedMetricCell(
                title: "Sealed days",
                value: "\(sealedDays)",
                artName: "IconStreak",
                accent: AppTheme.peach
            )
            IllustratedMetricCell(
                title: "Avg vitality",
                value: "\(Int(avgVitality.rounded()))",
                artName: ActivityKind.walkMinutes.artName,
                accent: AppTheme.apricot
            )
        }
    }

    private func barFraction(_ count: Int) -> CGFloat {
        let maxCount = max(1, store.slipRadar.map(\.count).max() ?? 1)
        return CGFloat(count) / CGFloat(maxCount)
    }

    private func compact(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000.0)
        }
        return "\(value)"
    }
}
