//
//  QuestsView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct QuestsView: View {
    @EnvironmentObject private var store: PetStore
    @State private var sheetKind: ActivityKind?
    @State private var celebration: CareQuest?
    @State private var snapshotBeforeLog: [String: Int] = [:]
    @State private var selectedIntentions: Set<CarryIntention> = []
    @State private var residueNote = ""
    @State private var residueTag: SlipKind?
    @State private var showSealSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        SealScreenHeader(
                            title: "Evening seal",
                            subtitle: "Close the day. Carry three intentions. Leave a residue note."
                        )

                        ScreenHeroImage(art: .seal, height: 140)

                        if store.todayIsSealed {
                            sealedPanel
                        } else {
                            sealComposer
                        }

                        SealScreenHeader(
                            title: "Today’s care rails",
                            subtitle: "Fill these before you seal — they feed the living stem."
                        )

                        ForEach(store.quests) { quest in
                            SealRailCell(quest: quest) {
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
                    .zIndex(20)
                }

                if showSealSuccess {
                    RitualCompleteOverlay(
                        title: "Day sealed · intentions parked for morning",
                        artName: store.profile.species.artName
                    ) {
                        showSealSuccess = false
                    }
                    .zIndex(21)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .sheet(item: $sheetKind, onDismiss: handleSheetDismiss) { kind in
                AddActivitySheet(initialKind: kind)
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
            }
        }
        .transparentScreenChrome()
    }

    private var sealedPanel: some View {
        GroveCard(accent: AppTheme.moss) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    SealWaxMark(size: 44, accent: AppTheme.moss)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Day sealed")
                            .font(AppFont.semibold(18))
                            .foregroundStyle(AppTheme.moss)
                        Text("Intentions parked for Morning Brief")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.bark.opacity(0.7))
                    }
                    Spacer(minLength: 0)
                }

                if let seal = store.todaySeal {
                    SealResiduePanel(
                        note: seal.residueNote,
                        tag: seal.residueTag
                    )

                    SealIntentionList(intentions: seal.carryIntentions)
                }
            }
        }
    }

    private var sealComposer: some View {
        GroveCard(accent: AppTheme.dusk) {
            VStack(alignment: .leading, spacing: 16) {
                SealScreenHeader(
                    title: "Park tomorrow’s three",
                    subtitle: "Pick up to three intentions the Morning Brief will carry."
                )

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(CarryIntention.allCases) { intention in
                        SealIntentionTile(
                            intention: intention,
                            isSelected: selectedIntentions.contains(intention),
                            isDisabled: !selectedIntentions.contains(intention)
                                && selectedIntentions.count >= 3
                        ) {
                            toggleIntention(intention)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Residue note")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                    GroveNoteField(
                        placeholder: "What still clung to the stem today?",
                        text: $residueNote
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Optional slip tag")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SealSlipChip(
                                title: "None",
                                accent: AppTheme.groveFog,
                                isSelected: residueTag == nil
                            ) {
                                residueTag = nil
                            }

                            ForEach(SlipKind.allCases) { kind in
                                SealSlipChip(
                                    title: kind.title,
                                    accent: kind.sealAccent,
                                    isSelected: residueTag == kind,
                                    glyph: kind
                                ) {
                                    residueTag = kind
                                }
                            }
                        }
                    }
                }

                GroveButton(
                    title: "Seal this day",
                    style: .primary,
                    isEnabled: !selectedIntentions.isEmpty,
                    artName: "TabSeal"
                ) {
                    store.sealDay(
                        intentions: Array(selectedIntentions),
                        residueNote: residueNote,
                        residueTag: residueTag
                    )
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                        showSealSuccess = true
                    }
                }
            }
        }
    }

    private func toggleIntention(_ intention: CarryIntention) {
        if selectedIntentions.contains(intention) {
            selectedIntentions.remove(intention)
        } else if selectedIntentions.count < 3 {
            selectedIntentions.insert(intention)
        }
    }

    private func handleSheetDismiss() {
        let newlyCompleted = store.quests.first { quest in
            let before = snapshotBeforeLog[quest.id] ?? 0
            return quest.isComplete && before < quest.target
        }
        if let newlyCompleted {
            withAnimation { celebration = newlyCompleted }
        }
        snapshotBeforeLog = [:]
    }
}

// MARK: - Seal custom UI

private struct SealScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SealWaxMark(size: 34, accent: AppTheme.dusk)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.soil)
                if let subtitle {
                    Text(subtitle)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SealWaxMark: View {
    var size: CGFloat = 40
    var accent: Color = AppTheme.moss

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.95), accent.opacity(0.55)],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: accent.opacity(0.35), radius: 6, y: 3)

            Circle()
                .stroke(AppTheme.pulp.opacity(0.55), lineWidth: 1.5)
                .frame(width: size * 0.72, height: size * 0.72)

            Capsule()
                .fill(AppTheme.pulp.opacity(0.9))
                .frame(width: size * 0.18, height: size * 0.42)
                .rotationEffect(.degrees(-18))
                .offset(x: -size * 0.06)

            Capsule()
                .fill(AppTheme.pulp.opacity(0.75))
                .frame(width: size * 0.14, height: size * 0.34)
                .rotationEffect(.degrees(28))
                .offset(x: size * 0.1, y: size * 0.02)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct SealIntentionTile: View {
    let intention: CarryIntention
    let isSelected: Bool
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ArtThumb(name: intention.artName, size: 40)
                    Spacer(minLength: 0)
                    SealSelectDot(isOn: isSelected, accent: intention.accent)
                }

                Text(intention.title)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(isSelected ? AppTheme.pulp : AppTheme.soil)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)

                Text(intention.detail)
                    .font(AppFont.medium(10))
                    .foregroundStyle(
                        isSelected
                            ? AppTheme.pulp.opacity(0.82)
                            : AppTheme.bark.opacity(0.62)
                    )
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [intention.accent, AppTheme.canopy]
                                : [AppTheme.pulp.opacity(0.92), intention.accent.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isSelected ? AppTheme.pulp.opacity(0.55) : Color.white.opacity(0.5),
                                lineWidth: isSelected ? 1.6 : 1
                            )
                    )
                    .shadow(
                        color: AppDepth.softShadow,
                        radius: isSelected ? 12 : 6,
                        y: isSelected ? 6 : 3
                    )
            )
        }
        .buttonStyle(GrovePressStyle())
        .disabled(isDisabled && !isSelected)
        .opacity(isDisabled && !isSelected ? 0.45 : 1)
    }
}

private struct SealSelectDot: View {
    let isOn: Bool
    var accent: Color = AppTheme.leaf

    var body: some View {
        ZStack {
            Circle()
                .stroke(isOn ? AppTheme.pulp : accent.opacity(0.55), lineWidth: 1.6)
                .frame(width: 20, height: 20)
            if isOn {
                Circle()
                    .fill(AppTheme.pulp)
                    .frame(width: 10, height: 10)
            }
        }
    }
}

private struct SealSlipChip: View {
    let title: String
    var accent: Color
    var isSelected: Bool
    var glyph: SlipKind? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let glyph {
                    SealSlipGlyph(kind: glyph, size: 18, lit: isSelected)
                } else {
                    Circle()
                        .fill(isSelected ? AppTheme.pulp : accent.opacity(0.55))
                        .frame(width: 10, height: 10)
                }

                Text(title)
                    .font(AppTheme.captionFont)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? AppTheme.pulp : AppTheme.canopy)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                colors: [accent, AppTheme.canopy],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [AppTheme.pulp.opacity(0.9), accent.opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(
                                isSelected ? AppTheme.pulp.opacity(0.45) : Color.white.opacity(0.5),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(GrovePressStyle())
    }
}

private struct SealSlipGlyph: View {
    let kind: SlipKind
    var size: CGFloat = 18
    var lit: Bool = false

    private var ink: Color { lit ? AppTheme.pulp : kind.sealAccent }

    var body: some View {
        ZStack {
            switch kind {
            case .weather:
                Capsule()
                    .fill(ink.opacity(0.85))
                    .frame(width: size * 0.9, height: size * 0.45)
                    .offset(y: -size * 0.08)
                Capsule()
                    .fill(ink.opacity(0.55))
                    .frame(width: size * 0.18, height: size * 0.35)
                    .offset(y: size * 0.18)
            case .workCrush:
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(ink)
                    .frame(width: size * 0.75, height: size * 0.55)
                Capsule()
                    .fill(ink.opacity(0.7))
                    .frame(width: size * 0.35, height: size * 0.16)
                    .offset(y: -size * 0.28)
            case .fatigue:
                Capsule()
                    .fill(ink)
                    .frame(width: size * 0.55, height: size * 0.75)
                    .offset(x: -size * 0.08)
                Circle()
                    .fill(ink.opacity(0.55))
                    .frame(width: size * 0.28, height: size * 0.28)
                    .offset(x: size * 0.22, y: -size * 0.12)
            case .mood:
                Circle()
                    .stroke(ink, lineWidth: 1.6)
                    .frame(width: size * 0.72, height: size * 0.72)
                Capsule()
                    .fill(ink)
                    .frame(width: size * 0.42, height: size * 0.1)
                    .rotationEffect(.degrees(-35))
            case .travel:
                Capsule()
                    .fill(ink)
                    .frame(width: size, height: size * 0.22)
                Capsule()
                    .fill(ink.opacity(0.75))
                    .frame(width: size * 0.22, height: size * 0.7)
            case .other:
                HStack(spacing: size * 0.12) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(ink)
                            .frame(width: size * 0.18, height: size * 0.18)
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }
}

private struct SealResiduePanel: View {
    let note: String
    let tag: SlipKind?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.isEmpty ? "No residue note left." : note)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.bark.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.pulp.opacity(0.72))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppTheme.moss.opacity(0.2), lineWidth: 1)
                        )
                )

            if let tag {
                HStack(spacing: 8) {
                    SealSlipGlyph(kind: tag, size: 16, lit: false)
                    Text("Residue tag · \(tag.title)")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.dusk)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(tag.sealAccent.opacity(0.16))
                )
            }
        }
    }
}

private struct SealIntentionList: View {
    let intentions: [CarryIntention]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(intentions) { intention in
                HStack(spacing: 10) {
                    ArtThumb(name: intention.artName, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(intention.title)
                            .font(AppFont.semibold(14))
                            .foregroundStyle(AppTheme.soil)
                        Text(intention.detail)
                            .font(AppFont.medium(11))
                            .foregroundStyle(AppTheme.bark.opacity(0.65))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    SealSelectDot(isOn: true, accent: intention.accent)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.pulp.opacity(0.9),
                                    intention.accent.opacity(0.14)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
    }
}

private struct SealRailCell: View {
    let quest: CareQuest
    let onLog: () -> Void

    @State private var fillPulse = 0
    @State private var showBurst = false
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
                    SealWaxMark(size: 36, accent: AppTheme.moss)
                        .scaleEffect(1.05)
                        .transition(.scale.combined(with: .opacity))
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
                    GroveButton(
                        title: "Log",
                        style: .soft,
                        artName: quest.kind.artName,
                        action: onLog
                    )
                    .frame(width: 118)
                } else {
                    Text("Rail filled")
                        .font(AppFont.semibold(12))
                        .foregroundStyle(AppTheme.moss)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(AppTheme.moss.opacity(0.16))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.82),
                            (quest.isComplete ? AppTheme.moss : AppTheme.peach).opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
                .shadow(color: AppDepth.softShadow, radius: 10, y: 6)
        )
        .ritualFillPulse(trigger: fillPulse)
        .onAppear { lastProgress = quest.progress }
        .onChange(of: quest.progress) { _, newValue in
            guard newValue != lastProgress else { return }
            lastProgress = newValue
            fillPulse += 1
            showBurst = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showBurst = false
            }
        }
    }
}

private extension SlipKind {
    var sealAccent: Color {
        switch self {
        case .weather: return AppTheme.groveFog
        case .workCrush: return AppTheme.dusk
        case .fatigue: return AppTheme.wilt
        case .mood: return AppTheme.peach
        case .travel: return AppTheme.leaf
        case .other: return AppTheme.bark
        }
    }
}
