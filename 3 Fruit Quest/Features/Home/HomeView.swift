//
//  HomeView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: PetStore
    @State private var showQuickLog = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        header
                        if let brief = store.morningBrief {
                            morningBriefCard(brief)
                        }
                        ScreenHeroImage(art: .stem, height: 140)
                        petStage
                        moodCard
                        metricsRow
                        quickActions
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppTheme.contentTop)
                    .padding(.bottom, AppTheme.tabBarClearance)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .sheet(isPresented: $showQuickLog) {
                AddActivitySheet(initialKind: .steps)
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
            }
        }
        .transparentScreenChrome()
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.7))
                Text(store.profile.name)
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.soil)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                StreakBadge(days: store.streakDays)
                Text(store.todayIsSealed ? "Sealed" : "Unsealed")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(store.todayIsSealed ? AppTheme.moss : AppTheme.dusk)
            }
        }
    }

    private func morningBriefCard(_ brief: MorningBrief) -> some View {
        GroveCard(accent: AppTheme.apricot) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Morning Brief", systemImage: "sun.horizon.fill")
                    .font(AppFont.semibold(18))
                    .foregroundStyle(AppTheme.dusk)

                Text(brief.quietWindowLabel)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.75))

                if !brief.residueNote.isEmpty {
                    Text("Yesterday’s residue: \(brief.residueNote)")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.soil)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Carried intentions")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                    ForEach(brief.carryIntentions) { intention in
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .foregroundStyle(AppTheme.leaf)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(intention.title)
                                    .font(AppFont.semibold(14))
                                    .foregroundStyle(AppTheme.soil)
                                Text(intention.detail)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.bark.opacity(0.7))
                            }
                        }
                    }
                }

                GroveButton(title: "Begin with these", style: .soft) {
                    store.dismissMorningBrief()
                }
            }
        }
    }

    private var petStage: some View {
        GroveCard {
            VStack(spacing: 14) {
                LivingFruitView(
                    species: store.profile.species,
                    mood: store.mood,
                    vitality: store.today.vitality,
                    bloomProgress: store.bloomProgress,
                    wiltFactor: store.wiltFactor,
                    width: 200
                )
                .frame(maxWidth: .infinity)

                SoftProgressBar(progress: store.stepProgress, tint: store.profile.species.ripeColor)
                HStack {
                    Text("\(store.today.steps) / \(store.profile.dailyStepGoal) steps")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.75))
                    Spacer()
                    Text("Vitality \(Int(store.today.vitality.rounded()))")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.canopy)
                }
            }
        }
    }

    private var moodCard: some View {
        GroveCard {
            HStack(spacing: 14) {
                ArtThumb(name: store.profile.species.artName, size: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(store.mood.title)
                        .font(AppFont.semibold(20))
                        .foregroundStyle(AppTheme.soil)
                    Text(store.mood.message)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.75))
                    if !store.todayIsSealed {
                        Text("Seal the day in the Seal tab to lock tonight’s carry.")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.dusk)
                    }
                }
            }
        }
    }

    private var metricsRow: some View {
        HStack(spacing: 10) {
            IllustratedMetricCell(
                title: "Walk",
                value: "\(store.today.walkMinutes)m",
                artName: ActivityKind.walkMinutes.artName,
                accent: AppTheme.leaf
            )
            IllustratedMetricCell(
                title: "Water",
                value: "\(store.today.water)",
                artName: ActivityKind.water.artName,
                accent: Color(red: 0.30, green: 0.55, blue: 0.70)
            )
            IllustratedMetricCell(
                title: "Stretch",
                value: "\(store.today.stretchMinutes)m",
                artName: ActivityKind.stretch.artName,
                accent: AppTheme.peach
            )
        }
    }

    private var quickActions: some View {
        GroveCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(
                    title: "Quick ledger",
                    subtitle: "Manual entries only — honesty over sensors."
                )
                HStack(spacing: 10) {
                    GrovePillButton(title: "+1k", artName: ActivityKind.steps.artName) {
                        store.addEntry(kind: .steps, amount: 1000)
                    }
                    GrovePillButton(title: "+10m", artName: ActivityKind.walkMinutes.artName) {
                        store.addEntry(kind: .walkMinutes, amount: 10)
                    }
                    GroveButton(title: "Custom", style: .soft) {
                        showQuickLog = true
                    }
                }
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning stem check"
        case 12..<17: return "Afternoon stem check"
        case 17..<22: return "Evening seal window"
        default: return "Late stem check"
        }
    }
}
