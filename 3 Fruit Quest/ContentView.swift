//
//  ContentView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = PetStore()
    @State private var selectedTab: AppTab = .home
    @State private var tabBarHiddenCount = 0

    var body: some View {
        Group {
            if store.profile.onboardingCompleted {
                mainShell
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environment(\.tabBarHiddenCount, $tabBarHiddenCount)
    }

    private var mainShell: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .log:
                    ActivityLogView()
                case .quests:
                    QuestsView()
                case .insights:
                    InsightsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if tabBarHiddenCount == 0 {
                CustomTabBar(selection: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
