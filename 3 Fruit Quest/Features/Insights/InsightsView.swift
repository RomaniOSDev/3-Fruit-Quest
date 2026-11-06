//
//  InsightsView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var store: PetStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        SectionHeader(
                            title: "Weekly pulse",
                            subtitle: "Vitality from your manual entries over seven days."
                        )

                        ScreenHeroImage(art: .pulse, height: 140)
                        vitalityChart
                        weeklyStats
                        companionSettings
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

    private var vitalityChart: some View {
        GroveCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Vitality trend")
                    .font(AppFont.semibold(17))
                    .foregroundStyle(AppTheme.soil)

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(store.recentDays) { day in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            store.profile.species.ripeColor.opacity(0.35 + day.vitality / 140),
                                            store.profile.species.leafAccent.opacity(0.8)
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(height: max(12, CGFloat(day.vitality) * 1.35))

                            Text(shortDay(day.dayKey))
                                .font(AppFont.medium(11))
                                .foregroundStyle(AppTheme.bark.opacity(0.65))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 160, alignment: .bottom)
            }
        }
    }

    private var weeklyStats: some View {
        let days = store.recentDays
        let totalSteps = days.reduce(0) { $0 + $1.steps }
        let avgVitality = days.isEmpty ? 0 : days.reduce(0.0) { $0 + $1.vitality } / Double(days.count)
        let activeDays = days.filter { $0.steps > 0 || $0.walkMinutes > 0 }.count

        return HStack(spacing: 10) {
            IllustratedMetricCell(
                title: "7-day steps",
                value: compact(totalSteps),
                artName: ActivityKind.steps.artName
            )
            IllustratedMetricCell(
                title: "Avg vitality",
                value: "\(Int(avgVitality.rounded()))",
                artName: "IconStreak",
                accent: AppTheme.peach
            )
            IllustratedMetricCell(
                title: "Active days",
                value: "\(activeDays)",
                artName: ActivityKind.walkMinutes.artName,
                accent: AppTheme.apricot
            )
        }
    }

    private var companionSettings: some View {
        GroveCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(
                    title: "Need a tune-up?",
                    subtitle: "Companion prefs, rate, policy and terms live in Nest."
                )
                HStack(spacing: 12) {
                    ArtThumb(name: store.profile.species.artName, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.profile.name)
                            .font(AppFont.semibold(17))
                            .foregroundStyle(AppTheme.soil)
                        Text("Goal \(store.profile.dailyStepGoal) steps")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.bark.opacity(0.7))
                    }
                    Spacer()
                }
            }
        }
    }

    private func shortDay(_ key: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: key) else { return "—" }
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US")
        out.dateFormat = "EEE"
        return out.string(from: date)
    }

    private func compact(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000.0)
        }
        return "\(value)"
    }
}
