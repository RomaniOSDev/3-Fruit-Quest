//
//  ActivityLogView.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject private var store: PetStore
    @State private var sheetKind: ActivityKind?
    @State private var draftKind: ActivityKind = .steps

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        header

                        ScreenHeroImage(art: .log, height: 140)
                        kindPicker
                        addEntryButton

                        if store.todaysEntries().isEmpty {
                            IllustratedEmptyHint(
                                title: "Ledger is empty",
                                detail: "Add steps, walks, water, or stretches — then seal the day when ready.",
                                artName: "IconEmptyLog"
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(store.todaysEntries()) { entry in
                                    IllustratedActivityCell(entry: entry) {
                                        store.deleteEntry(entry)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppTheme.contentTop)
                    .padding(.bottom, AppTheme.tabBarClearance)
                }
                .clearScrollBackground()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .sheet(item: $sheetKind) { kind in
                AddActivitySheet(initialKind: kind)
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
            }
        }
        .transparentScreenChrome()
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Movement ledger")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.soil)
                Text("Typed by hand — no Health sync, no silent padding.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.bark.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .allowsHitTesting(false)

            Button {
                openAdd(draftKind)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.pulp)
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.canopy, AppTheme.leaf],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: AppTheme.canopy.opacity(0.28), radius: 10, y: 5)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add entry")
        }
    }

    private var addEntryButton: some View {
        Button {
            openAdd(draftKind)
        } label: {
            HStack(spacing: 10) {
                ArtThumb(name: draftKind.artName, size: 28)
                Text("Add \(draftKind.title.lowercased())")
                    .font(AppTheme.buttonFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(AppTheme.pulp)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.canopy, AppTheme.leaf],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppTheme.canopy.opacity(0.28), radius: 10, y: 5)
            )
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var kindPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    IllustratedKindChip(kind: kind, isSelected: draftKind == kind) {
                        draftKind = kind
                        openAdd(kind)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func openAdd(_ kind: ActivityKind) {
        draftKind = kind
        sheetKind = kind
    }
}
