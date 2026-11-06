//
//  AddActivitySheet.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct AddActivitySheet: View {
    @EnvironmentObject private var store: PetStore
    @Environment(\.dismiss) private var dismiss

    let initialKind: ActivityKind

    @State private var kind: ActivityKind
    @State private var amountText = ""
    @State private var note = ""

    init(initialKind: ActivityKind) {
        self.initialKind = initialKind
        _kind = State(initialValue: initialKind)
    }

    private var amount: Int { Int(amountText) ?? 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        SectionHeader(
                            title: "Add activity",
                            subtitle: "Typed in by you — nothing is pulled from Health."
                        )

                        kindSelector
                        amountField
                        suggestionRow

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note (optional)")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.bark.opacity(0.7))
                            TextField("Morning loop, park path…", text: $note)
                                .font(AppTheme.bodyFont)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white.opacity(0.75))
                                )
                        }

                        GroveButton(title: "Save entry", style: .primary, isEnabled: amount > 0) {
                            store.addEntry(kind: kind, amount: amount, note: note)
                            dismiss()
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppTheme.contentTop)
                    .padding(.bottom, AppTheme.contentBottom)
                }
                .clearScrollBackground()
            }
            .navigationTitle("New entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(AppFont.semibold(16))
                            .foregroundStyle(AppTheme.canopy)
                    }
                }
            }
        }
    }

    private var kindSelector: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(ActivityKind.allCases) { item in
                Button {
                    kind = item
                    amountText = ""
                } label: {
                    VStack(spacing: 8) {
                        ArtThumb(name: item.artName, size: 52)
                        Text(item.title)
                            .font(AppFont.semibold(12))
                            .foregroundStyle(kind == item ? AppTheme.canopy : AppTheme.soil)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(item.accentHint)
                            .font(AppFont.medium(10))
                            .foregroundStyle(AppTheme.bark.opacity(0.65))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(kind == item ? 0.95 : 0.72),
                                        (kind == item ? AppTheme.leaf : AppTheme.apricot).opacity(0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(kind == item ? AppTheme.canopy : Color.white.opacity(0.5), lineWidth: kind == item ? 2 : 1)
                            )
                    )
                }
                .buttonStyle(GrovePressStyle())
            }
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kind.title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.bark.opacity(0.7))
            HStack {
                TextField("0", text: $amountText)
                    .keyboardType(.numberPad)
                    .font(AppTheme.metricFont)
                    .foregroundStyle(AppTheme.soil)
                Text(kind.unitLabel)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.65))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.75))
            )
        }
    }

    private var suggestionRow: some View {
        HStack(spacing: 8) {
            ForEach(kind.suggestedAmounts, id: \.self) { value in
                GrovePillButton(title: "+\(value)", isSelected: amountText == "\(value)") {
                    amountText = "\(value)"
                }
            }
        }
    }
}
