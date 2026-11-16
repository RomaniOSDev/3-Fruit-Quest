//
//  CustomTabBar.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case log
    case quests
    case insights
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Stem"
        case .log: return "Ledger"
        case .quests: return "Seal"
        case .insights: return "Radar"
        case .settings: return "Roots"
        }
    }

    var artName: String {
        switch self {
        case .home: return "TabStem"
        case .log: return "TabLedger"
        case .quests: return "TabSeal"
        case .insights: return "TabRadar"
        case .settings: return "TabRoots"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: AppTab
    @State private var hop = false

    var body: some View {
        ZStack(alignment: .bottom) {
            dockBackdrop

            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, AppTheme.screenPadding)
        .padding(.bottom, 8)
        .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                hop = true
            }
        }
    }

    private var dockBackdrop: some View {
        Image("TabDock")
            .resizable()
            .scaledToFill()
            .frame(height: 86)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.16),
                                AppTheme.canopy.opacity(0.35)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: AppDepth.liftShadow, radius: 18, y: 10)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let selected = selection == tab

        return Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.68)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selected {
                        Circle()
                            .fill(AppTheme.pulp.opacity(0.95))
                            .frame(width: 48, height: 48)
                            .shadow(color: AppTheme.dusk.opacity(0.4), radius: 10, y: 4)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.apricot.opacity(0.75), lineWidth: 2)
                            )
                    }

                    Image(tab.artName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: selected ? 40 : 34, height: selected ? 40 : 34)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 1))
                        .scaleEffect(selected && hop ? 1.05 : 1.0)
                        .offset(y: selected ? -12 : 0)
                }
                .frame(height: 56)

                Text(tab.title)
                    .font(selected ? AppFont.bold(10) : AppFont.semibold(10))
                    .foregroundStyle(selected ? Color.white : Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}
