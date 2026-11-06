//
//  LivingFruitView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct LivingFruitView: View {
    let species: FruitSpecies
    let mood: PetMood
    let vitality: Double
    let bloomProgress: Double
    let wiltFactor: Double
    /// Target width in points. Layout frame matches this size.
    var width: CGFloat = 220

    @State private var bounce = false
    @State private var wink = false
    @State private var spinLeaf = false

    private var height: CGFloat { width * 1.08 }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let energy = max(0.25, 1 - wiltFactor)
            let sway = sin(t * (0.9 + energy)) * (5 + wiltFactor * 8)
            let floatY = sin(t * (1.2 + bloomProgress)) * (6 * energy)
            let pulse = 1 + sin(t * 2.1) * (0.02 + bloomProgress * 0.03)

            ZStack {
                aura(time: t)
                    .scaleEffect(pulse)

                fruitArt
                    .scaleEffect(x: pulse * (bounce ? 1.04 : 0.97), y: pulse * (bounce ? 0.96 : 1.03))
                    .rotationEffect(.degrees(sway * 0.22 + (mood == .wilted ? 4 : 0)))
                    .offset(y: floatY + wiltFactor * 10)
                    .saturation(1.05 - wiltFactor * 0.75)
                    .brightness(bloomProgress * 0.04 - wiltFactor * 0.08)
                    .shadow(
                        color: species.ripeColor.opacity(0.28 + bloomProgress * 0.25),
                        radius: 16 + bloomProgress * 8,
                        y: 10
                    )

                if bloomProgress > 0.45 {
                    sparkles(time: t)
                }

                if mood == .radiant || mood == .blooming {
                    confettiBits(time: t)
                }
            }
            .frame(width: width, height: height)
        }
        .frame(width: width, height: height)
        .onAppear { startLoops() }
        .onChange(of: mood) { _, _ in
            playMoodPop()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(species.displayName), mood \(mood.title)")
    }

    private var fruitArt: some View {
        Image(species.artName)
            .resizable()
            .scaledToFit()
            .frame(width: width * 0.92, height: height * 0.92)
            .clipShape(RoundedRectangle(cornerRadius: width * 0.18, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Image(systemName: mood.symbolName)
                    .font(.system(size: max(12, width * 0.09), weight: .bold))
                    .foregroundStyle(AppTheme.pulp)
                    .padding(8)
                    .background(Circle().fill(species.ripeColor.opacity(0.9)))
                    .offset(x: -4, y: 8)
                    .scaleEffect(wink ? 1.12 : 0.92)
                    .opacity(0.95)
            }
            .overlay {
                RoundedRectangle(cornerRadius: width * 0.18, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
            }
    }

    private func aura(time: Double) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        species.ripeColor.opacity(0.45 * (1 - wiltFactor)),
                        species.fleshColor.opacity(0.18),
                        .clear
                    ],
                    center: .center,
                    startRadius: width * 0.08,
                    endRadius: width * 0.58
                )
            )
            .frame(width: width * 1.05, height: width * 1.05)
            .blur(radius: 10)
            .scaleEffect(spinLeaf ? 1.06 : 0.94)
            .opacity(0.55 + bloomProgress * 0.35)
    }

    private func sparkles(time: Double) -> some View {
        ForEach(0..<7, id: \.self) { index in
            let angle = Double(index) / 7 * .pi * 2 + time * 0.55
            let radius = width * (0.42 + 0.04 * sin(time + Double(index)))
            Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "star.fill")
                .font(.system(size: max(8, width * 0.05)))
                .foregroundStyle(AppTheme.apricot.opacity(0.85))
                .offset(x: cos(angle) * radius, y: sin(angle) * radius * 0.82)
                .scaleEffect(0.7 + 0.35 * abs(sin(time * 2 + Double(index))))
        }
        .allowsHitTesting(false)
    }

    private func confettiBits(time: Double) -> some View {
        ForEach(0..<5, id: \.self) { index in
            let drift = sin(time * 1.4 + Double(index) * 1.7)
            Capsule()
                .fill(index.isMultiple(of: 2) ? species.ripeColor : AppTheme.peach)
                .frame(width: 5, height: 12)
                .rotationEffect(.degrees(Double(index) * 36 + time * 40))
                .offset(
                    x: CGFloat(drift) * width * 0.28,
                    y: -height * 0.38 + CGFloat(sin(time + Double(index))) * 10
                )
                .opacity(0.55)
        }
        .allowsHitTesting(false)
    }

    private func startLoops() {
        withAnimation(.easeInOut(duration: mood == .wilted ? 2.8 : 1.35).repeatForever(autoreverses: true)) {
            bounce = true
        }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            wink = true
        }
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            spinLeaf = true
        }
    }

    private func playMoodPop() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
            bounce = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeInOut(duration: mood == .wilted ? 2.8 : 1.35).repeatForever(autoreverses: true)) {
                bounce = true
            }
        }
    }
}
