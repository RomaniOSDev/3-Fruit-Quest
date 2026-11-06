//
//  PetStore.swift
//  3 Fruit Quest
//
//  Created by Roman on 10/30/26.
//

import Foundation
import Combine

@MainActor
final class PetStore: ObservableObject {
    @Published private(set) var profile: PetProfile
    @Published private(set) var entries: [ActivityEntry]
    @Published private(set) var today: DaySnapshot

    private let defaults: UserDefaults
    private let profileKey = "fq.pet.profile"
    private let entriesKey = "fq.pet.entries"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.profile = Self.loadProfile(from: defaults, key: profileKey) ?? .blank
        self.entries = Self.loadEntries(from: defaults, key: entriesKey)
        self.today = DaySnapshot.empty(dayKey: Self.todayKey())
        refreshToday()
    }

    var mood: PetMood { PetMood.from(vitality: today.vitality) }

    var bloomProgress: Double { VitalityEngine.bloomProgress(vitality: today.vitality) }

    var wiltFactor: Double { VitalityEngine.wiltFactor(vitality: today.vitality) }

    var stepProgress: Double {
        let goal = max(1, profile.dailyStepGoal)
        return min(1, Double(today.steps) / Double(goal))
    }

    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())

        while true {
            let key = ActivityEntry.dayFormatter.string(from: cursor)
            let snapshot = snapshot(for: key)
            if snapshot.steps >= max(1000, profile.dailyStepGoal / 4) || snapshot.vitality >= 50 {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = previous
            } else {
                break
            }
        }
        return streak
    }

    var recentDays: [DaySnapshot] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset -> DaySnapshot? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let key = ActivityEntry.dayFormatter.string(from: date)
            return snapshot(for: key)
        }.reversed()
    }

    var quests: [CareQuest] {
        [
            CareQuest(
                id: "steps",
                title: "Feed the glow",
                detail: "Log steps toward today's goal",
                symbolName: "figure.walk",
                target: profile.dailyStepGoal,
                progress: today.steps,
                kind: .steps
            ),
            CareQuest(
                id: "walk",
                title: "Orchard stroll",
                detail: "Add focused walk minutes",
                symbolName: "timer",
                target: 30,
                progress: today.walkMinutes,
                kind: .walkMinutes
            ),
            CareQuest(
                id: "water",
                title: "Hydrate the roots",
                detail: "Track water glasses manually",
                symbolName: "drop.fill",
                target: 6,
                progress: today.water,
                kind: .water
            ),
            CareQuest(
                id: "stretch",
                title: "Loosen the stem",
                detail: "A few stretch minutes keep color vivid",
                symbolName: "figure.flexibility",
                target: 10,
                progress: today.stretchMinutes,
                kind: .stretch
            )
        ]
    }

    func completeOnboarding(name: String, species: FruitSpecies, dailyStepGoal: Int) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile = PetProfile(
            name: trimmed.isEmpty ? species.displayName : trimmed,
            species: species,
            dailyStepGoal: dailyStepGoal,
            createdAt: Date(),
            onboardingCompleted: true
        )
        persistProfile()
        refreshToday()
    }

    func updateGoal(_ goal: Int) {
        profile.dailyStepGoal = max(1000, min(30000, goal))
        persistProfile()
        refreshToday()
    }

    func renamePet(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        profile.name = trimmed
        persistProfile()
    }

    func changeSpecies(_ species: FruitSpecies) {
        profile.species = species
        persistProfile()
    }

    func addEntry(kind: ActivityKind, amount: Int, note: String = "") {
        guard amount > 0 else { return }
        entries.insert(ActivityEntry(kind: kind, amount: amount, note: note), at: 0)
        persistEntries()
        refreshToday()
    }

    func deleteEntry(_ entry: ActivityEntry) {
        entries.removeAll { $0.id == entry.id }
        persistEntries()
        refreshToday()
    }

    func todaysEntries() -> [ActivityEntry] {
        let key = Self.todayKey()
        return entries.filter { $0.dayKey == key }
    }

    func snapshot(for dayKey: String) -> DaySnapshot {
        VitalityEngine.aggregate(
            entries: entries,
            dayKey: dayKey,
            dailyStepGoal: profile.dailyStepGoal
        )
    }

    func refreshToday() {
        today = snapshot(for: Self.todayKey())
    }

    private func persistProfile() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: profileKey)
    }

    private func persistEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: entriesKey)
    }

    private static func todayKey() -> String {
        ActivityEntry.dayFormatter.string(from: Date())
    }

    private static func loadProfile(from defaults: UserDefaults, key: String) -> PetProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PetProfile.self, from: data)
    }

    private static func loadEntries(from defaults: UserDefaults, key: String) -> [ActivityEntry] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ActivityEntry].self, from: data)) ?? []
    }
}
