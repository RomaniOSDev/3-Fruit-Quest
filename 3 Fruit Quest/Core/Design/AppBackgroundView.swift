//
//  AppBackgroundView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.86, green: 0.93, blue: 0.89),
                    Color(red: 0.93, green: 0.90, blue: 0.82),
                    Color(red: 0.88, green: 0.84, blue: 0.74)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Circle()
                    .fill(AppTheme.moss.opacity(0.18))
                    .frame(width: geo.size.width * 0.72)
                    .blur(radius: 2)
                    .offset(x: -geo.size.width * 0.28, y: -geo.size.height * 0.08)

                Circle()
                    .fill(AppTheme.peach.opacity(0.22))
                    .frame(width: geo.size.width * 0.58)
                    .offset(x: geo.size.width * 0.48, y: geo.size.height * 0.18)

                Ellipse()
                    .fill(AppTheme.leaf.opacity(0.12))
                    .frame(width: geo.size.width * 1.1, height: geo.size.height * 0.42)
                    .offset(y: geo.size.height * 0.62)
            }
        }
        .ignoresSafeArea()
    }
}
