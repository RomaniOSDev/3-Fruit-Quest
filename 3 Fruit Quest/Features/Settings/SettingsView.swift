//
//  SettingsView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: PetStore
    @Environment(\.openURL) private var openURL
    @State private var draftName = ""
    @State private var draftGoal: Double = 8000

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        SectionHeader(
                            title: "Roots",
                            subtitle: "Stem prefs, quiet goals, and legal links."
                        )

                        companionCard
                        legalCard
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppTheme.contentTop)
                    .padding(.bottom, AppTheme.tabBarClearance)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .onAppear {
                draftName = store.profile.name
                draftGoal = Double(store.profile.dailyStepGoal)
            }
        }
        .transparentScreenChrome()
    }

    private var companionCard: some View {
        GroveCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Living stem", subtitle: "Name, pace, and fruit form.")

                HStack(spacing: 12) {
                    ArtThumb(name: store.profile.species.artName, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.profile.name)
                            .font(AppFont.semibold(18))
                            .foregroundStyle(AppTheme.soil)
                        Text(store.profile.species.displayName)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.bark.opacity(0.7))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                    HStack(spacing: 10) {
                        TextField("Name", text: $draftName)
                            .font(AppTheme.bodyFont)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.72))
                            )
                        GroveButton(title: "Save", style: .soft) {
                            store.renamePet(draftName)
                        }
                        .frame(width: 96)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily step goal · \(Int(draftGoal))")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                    Slider(value: $draftGoal, in: 3000...20000, step: 500) {
                        Text("Goal")
                    } onEditingChanged: { editing in
                        if !editing {
                            store.updateGoal(Int(draftGoal))
                        }
                    }
                    .tint(AppTheme.leaf)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(FruitSpecies.allCases) { species in
                            GrovePillButton(
                                title: species.displayName,
                                isSelected: store.profile.species == species,
                                artName: species.artName
                            ) {
                                store.changeSpecies(species)
                            }
                        }
                    }
                }
            }
        }
    }

    private var legalCard: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Support & legal",
                subtitle: "Rate, policy, and terms — URLs live in AppLinks."
            )

            GroveLinkRowButton(
                title: "Rate the app",
                subtitle: "Share a quick orchard review",
                artName: "IconRate",
                action: rateApp
            )

            GroveLinkRowButton(
                title: "Privacy Policy",
                subtitle: "How care data stays yours",
                artName: "IconPolicy"
            ) {
                openURL(AppLinks.privacyPolicy)
            }

            GroveLinkRowButton(
                title: "Terms of Use",
                subtitle: "The ground rules for play",
                artName: "IconTerms"
            ) {
                openURL(AppLinks.termsOfUse)
            }
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
