//
//  OnboardingView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: PetStore

    @State private var step = 0
    @State private var name = ""
    @State private var species: FruitSpecies = .avocado
    @State private var dailyGoal = 8000

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                progressDots
                    .padding(.top, AppTheme.contentTop)
                    .padding(.horizontal, AppTheme.screenPadding)

                TabView(selection: $step) {
                    welcomePage.tag(0)
                    speciesPage.tag(1)
                    namingPage.tag(2)
                    goalPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: step)

                bottomActions
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, AppTheme.contentBottom)
            }
        }
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? AppTheme.canopy : AppTheme.bark.opacity(0.2))
                    .frame(width: index == step ? 22 : 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var welcomePage: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                ScreenHeroImage(art: .onboarding, height: 168)

                LivingFruitView(
                    species: .peach,
                    mood: .blooming,
                    vitality: 78,
                    bloomProgress: 0.72,
                    wiltFactor: 0.12,
                    width: 180
                )

                VStack(spacing: 10) {
                    Text("Close the day. Carry the stem.")
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.soil)
                        .multilineTextAlignment(.center)
                    Text("A living fruit mirrors your movement. Seal evenings, brief mornings, and tag slips — all by hand, no Health sync.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppTheme.contentTop)
            .padding(.bottom, AppTheme.contentBottom)
        }
        .clearScrollBackground()
    }

    private var speciesPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                SectionHeader(
                    title: "Choose a companion",
                    subtitle: "Each fruit keeps its own palette and personality."
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(FruitSpecies.allCases) { item in
                        IllustratedSpeciesCell(
                            species: item,
                            isSelected: species == item
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                species = item
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppTheme.contentTop)
            .padding(.bottom, AppTheme.contentBottom)
        }
        .clearScrollBackground()
    }

    private var namingPage: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                LivingFruitView(
                    species: species,
                    mood: .blooming,
                    vitality: 70,
                    bloomProgress: 0.62,
                    wiltFactor: 0.14,
                    width: 180
                )

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Give it a name", subtitle: "Shown only as your companion’s name.")
                    TextField("Companion name", text: $name)
                        .font(AppTheme.bodyFont)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.75))
                        )
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppTheme.contentTop)
            .padding(.bottom, AppTheme.contentBottom)
        }
        .clearScrollBackground()
    }

    private var goalPage: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                VStack(spacing: 8) {
                    Text("\(dailyGoal)")
                        .font(AppFont.bold(52))
                        .foregroundStyle(AppTheme.soil)
                    Text("daily steps goal")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.75))
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(
                        title: "Set today’s pace",
                        subtitle: "You enter steps manually. This goal shapes seal readiness."
                    )
                    Slider(value: Binding(
                        get: { Double(dailyGoal) },
                        set: { dailyGoal = Int($0) }
                    ), in: 3000...20000, step: 500)
                    .tint(AppTheme.leaf)

                    HStack(spacing: 10) {
                        goalPreset(5000)
                        goalPreset(8000)
                        goalPreset(10000)
                    }
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 28)
            .padding(.bottom, AppTheme.contentBottom)
        }
        .clearScrollBackground()
    }

    private func goalPreset(_ value: Int) -> some View {
        GrovePillButton(title: "\(value)", isSelected: dailyGoal == value) {
            dailyGoal = value
        }
    }

    private var bottomActions: some View {
        HStack(spacing: 12) {
            if step > 0 {
                GroveButton(title: "Back", style: .secondary) {
                    withAnimation { step -= 1 }
                }
            }

            GroveButton(title: step == 3 ? "Open the stem" : "Continue", style: .primary) {
                if step < 3 {
                    withAnimation { step += 1 }
                } else {
                    store.completeOnboarding(
                        name: name,
                        species: species,
                        dailyStepGoal: dailyGoal
                    )
                }
            }
        }
    }
}
