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
                    Color(red: 0.70, green: 0.78, blue: 0.72),
                    Color(red: 0.86, green: 0.78, blue: 0.62),
                    Color(red: 0.55, green: 0.48, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Circle()
                    .fill(AppTheme.canopy.opacity(0.22))
                    .frame(width: geo.size.width * 0.85)
                    .offset(x: -geo.size.width * 0.35, y: -geo.size.height * 0.12)

                Circle()
                    .fill(AppTheme.dusk.opacity(0.28))
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: geo.size.width * 0.42, y: geo.size.height * 0.22)

                Ellipse()
                    .fill(AppTheme.leaf.opacity(0.14))
                    .frame(width: geo.size.width * 1.2, height: geo.size.height * 0.38)
                    .offset(y: geo.size.height * 0.68)
            }
        }
        .ignoresSafeArea()
    }
}
