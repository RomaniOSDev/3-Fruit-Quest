//
//  RitualAnimations.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct RitualProgressBar: View {
    let progress: Double
    var tint: Color = AppTheme.leaf
    var isComplete: Bool = false

    @State private var displayed: Double = 0
    @State private var shimmer = false
    @State private var pulse = false

    var body: some View {
        GeometryReader { geo in
            let width = max(10, geo.size.width * max(0, min(1, displayed)))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.bark.opacity(0.12))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                tint,
                                tint.opacity(0.75),
                                isComplete ? AppTheme.apricot : tint.opacity(0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width)
                    .shadow(color: tint.opacity(0.45), radius: pulse ? 10 : 4, y: 0)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.white.opacity(0.55),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 36)
                            .offset(x: shimmer ? width - 20 : -40)
                            .opacity(displayed > 0.05 ? 1 : 0)
                            .mask(
                                Capsule().frame(width: width)
                            )
                    }

                if isComplete {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(AppTheme.pulp)
                            .frame(width: 6, height: 6)
                            .padding(.trailing, 8)
                    }
                    .frame(width: width)
                }
            }
        }
        .frame(height: 12)
        .onAppear {
            displayed = progress
            startLoops()
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                displayed = newValue
            }
            withAnimation(.easeOut(duration: 0.35)) {
                pulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    pulse = false
                }
            }
        }
    }

    private func startLoops() {
        withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
            shimmer = true
        }
    }
}

struct RitualSparkBurst: View {
    var accent: Color = AppTheme.apricot
    @State private var expand = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                let angle = Double(index) / 10 * .pi * 2
                let leaf = index.isMultiple(of: 2)
                Group {
                    if leaf {
                        Capsule()
                            .fill(AppTheme.leaf)
                            .frame(width: 8, height: 14)
                            .rotationEffect(.degrees(Double(index) * 36))
                    } else {
                        Circle()
                            .fill(accent)
                            .frame(width: index.isMultiple(of: 3) ? 7 : 5, height: index.isMultiple(of: 3) ? 7 : 5)
                    }
                }
                .offset(
                    x: expand ? cos(angle) * 56 : 0,
                    y: expand ? sin(angle) * 40 : 0
                )
                .opacity(expand ? 0 : 1)
                .scaleEffect(expand ? 1.3 : 0.3)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.85)) {
                expand = true
            }
        }
    }
}

struct RitualCompleteOverlay: View {
    let title: String
    let artName: String
    let onFinished: () -> Void

    @State private var appear = false
    @State private var glow = false

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.28 : 0)
                .ignoresSafeArea()
                .onTapGesture(perform: dismiss)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.moss.opacity(0.25))
                        .frame(width: 140, height: 140)
                        .scaleEffect(glow ? 1.15 : 0.9)

                    ArtThumb(name: artName, size: 88)
                        .scaleEffect(appear ? 1 : 0.4)
                        .rotationEffect(.degrees(appear ? 0 : -18))

                    RitualSparkBurst(accent: AppTheme.apricot)
                }

                Text("Ritual complete")
                    .font(AppFont.bold(26))
                    .foregroundStyle(AppTheme.soil)

                Text(title)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.8))
                    .multilineTextAlignment(.center)

                GroveButton(title: "Keep blooming", style: .primary, action: dismiss)
                    .padding(.horizontal, 28)
                    .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.pulp.opacity(0.96))
                    .shadow(color: AppDepth.liftShadow, radius: 24, y: 12)
            )
            .scaleEffect(appear ? 1 : 0.82)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.68)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                glow = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.22)) {
            appear = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onFinished()
        }
    }
}

struct RitualFillPulse: ViewModifier {
    let trigger: Int
    @State private var bounce = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(bounce ? 1.035 : 1)
            .onChange(of: trigger) { _, _ in
                withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
                    bounce = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        bounce = false
                    }
                }
            }
    }
}

extension View {
    func ritualFillPulse(trigger: Int) -> some View {
        modifier(RitualFillPulse(trigger: trigger))
    }
}
