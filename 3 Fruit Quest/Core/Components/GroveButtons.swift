//
//  GroveButtons.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

enum GroveButtonStyleKind {
    case primary
    case secondary
    case soft
    case danger
}

struct GrovePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct GroveButton: View {
    let title: String
    var style: GroveButtonStyleKind = .primary
    var isEnabled: Bool = true
    var artName: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let artName {
                    ArtThumb(name: artName, size: 28)
                }
                Text(title)
                    .font(AppTheme.buttonFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 14)
            .background(background)
        }
        .buttonStyle(GrovePressStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
    }

    private var foreground: Color {
        switch style {
        case .primary: return AppTheme.pulp
        case .secondary, .soft: return AppTheme.canopy
        case .danger: return AppTheme.pulp
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.canopy, AppTheme.leaf],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.canopy.opacity(0.28), radius: 10, y: 5)
        case .secondary:
            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                        .stroke(AppTheme.canopy.opacity(0.35), lineWidth: 1.2)
                )
        case .soft:
            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.pulp, AppTheme.blossom.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        case .danger:
            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                .fill(AppTheme.dangerSoft)
        }
    }
}

struct GroveIconButton: View {
    var systemName: String? = nil
    var artName: String? = nil
    var size: CGFloat = 54
    var fill: Color = AppTheme.canopy
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [fill, fill.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                if let artName {
                    ArtThumb(name: artName, size: size * 0.55)
                        .allowsHitTesting(false)
                } else if let systemName {
                    Image(systemName: systemName)
                        .font(.system(size: size * 0.36, weight: .bold))
                        .foregroundStyle(AppTheme.pulp)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: size, height: size)
            .shadow(color: fill.opacity(0.28), radius: 10, y: 5)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .frame(width: size, height: size)
    }
}

struct GrovePillButton: View {
    let title: String
    var isSelected: Bool = false
    var artName: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let artName {
                    ArtThumb(name: artName, size: 24)
                }
                Text(title)
                    .font(AppTheme.captionFont)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? AppTheme.pulp : AppTheme.canopy)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AppTheme.canopy : Color.white.opacity(0.72))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(isSelected ? AppTheme.leaf : Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(GrovePressStyle())
    }
}

struct GroveLinkRowButton: View {
    let title: String
    let subtitle: String
    let artName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ArtThumb(name: artName, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFont.semibold(17))
                        .foregroundStyle(AppTheme.soil)
                    Text(subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.bark.opacity(0.7))
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.leaf)
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.75)))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.88), AppTheme.leaf.opacity(0.12)],
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
        }
        .buttonStyle(GrovePressStyle())
    }
}

struct GroveNoteField: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 96

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.pulp.opacity(0.92),
                            AppTheme.blossom.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                        .stroke(AppTheme.canopy.opacity(0.22), lineWidth: 1.2)
                )

            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(placeholder)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.42))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.soil)
                .scrollContentBackground(.hidden)
                .tint(AppTheme.leaf)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(minHeight: minHeight)
        }
        .frame(minHeight: minHeight)
    }
}

/// Backwards-compatible alias used across screens.
struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        GroveButton(title: title, style: .primary, isEnabled: isEnabled, action: action)
    }
}
