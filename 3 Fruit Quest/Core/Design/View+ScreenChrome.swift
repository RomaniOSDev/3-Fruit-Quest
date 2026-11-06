//
//  View+ScreenChrome.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

private struct TabBarHiddenCountKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var tabBarHiddenCount: Binding<Int> {
        get { self[TabBarHiddenCountKey.self] }
        set { self[TabBarHiddenCountKey.self] = newValue }
    }
}

extension View {
    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }

    func transparentScreenChrome() -> some View {
        background(Color.clear)
    }

    func hidesTabBar() -> some View {
        modifier(HidesTabBarModifier())
    }
}

private struct HidesTabBarModifier: ViewModifier {
    @Environment(\.tabBarHiddenCount) private var tabBarHiddenCount

    func body(content: Content) -> some View {
        content
            .onAppear { tabBarHiddenCount.wrappedValue += 1 }
            .onDisappear { tabBarHiddenCount.wrappedValue = max(0, tabBarHiddenCount.wrappedValue - 1) }
    }
}
