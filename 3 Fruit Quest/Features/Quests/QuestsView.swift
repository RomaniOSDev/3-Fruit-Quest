//
//  QuestsView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct QuestsView: View {
    @EnvironmentObject private var store: PetStore
    @State private var selectedQuest: CareQuest?
    @State private var sheetKind: ActivityKind?
    @State private var celebration: CareQuest?
    @State private var snapshotBeforeLog: [String: Int] = [:]
    @State private var bloomPulse = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        SectionHeader(
                            title: "Care rituals",
                            subtitle: "Complete these to keep color sharp and leaves lifted."
                        )

                        ScreenHeroImage(art: .care, height: 140)
                        careSummary

                        ForEach(store.quests) { quest in
                            IllustratedQuestCell(quest: quest) {
                                selectedQuest = quest
                                snapshotBeforeLog = Dictionary(
                                    uniqueKeysWithValues: store.quests.map { ($0.id, $0.progress) }
                                )
                                sheetKind = quest.kind
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppTheme.contentTop)
                    .padding(.bottom, AppTheme.tabBarClearance)
                }
                .clearScrollBackground()

                if let celebration {
                    RitualCompleteOverlay(
                        title: celebration.title,
                        artName: celebration.kind.artName
                    ) {
                        self.celebration = nil
                    }
                    .transition(.opacity)
                    .zIndex(20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .sheet(item: $sheetKind, onDismiss: handleSheetDismiss) { kind in
                AddActivitySheet(initialKind: kind)
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: store.today.vitality) { _, _ in
                bloomPulse += 1
            }
        }
        .transparentScreenChrome()
    }

    private var careSummary: some View {
        GroveCard(accent: store.profile.species.ripeColor) {
            HStack(spacing: 14) {
                ZStack {
                    ArtThumb(name: store.profile.species.artName, size: 64)
                        .ritualFillPulse(trigger: bloomPulse)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Today’s bloom")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                    Text(store.mood.title)
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.soil)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.25), value: store.mood)
                    RitualProgressBar(
                        progress: store.bloomProgress,
                        tint: store.profile.species.ripeColor,
                        isComplete: store.bloomProgress >= 0.98
                    )
                    .frame(height: 10)
                }

                Spacer(minLength: 4)

                Text("\(Int(store.today.vitality.rounded()))")
                    .font(AppFont.bold(24))
                    .foregroundStyle(AppTheme.canopy)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.today.vitality)
                    .ritualFillPulse(trigger: bloomPulse)
            }
        }
    }

    private func handleSheetDismiss() {
        let newlyCompleted = store.quests.first { quest in
            let before = snapshotBeforeLog[quest.id] ?? 0
            return quest.isComplete && before < quest.target
        }

        if let newlyCompleted {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                celebration = newlyCompleted
            }
        }

        bloomPulse += 1
        selectedQuest = nil
        snapshotBeforeLog = [:]
    }
}
