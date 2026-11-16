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
    @Published private(set) var seals: [DaySeal]
    @Published private(set) var slips: [SlipEntry]
    @Published private(set) var today: DaySnapshot
    @Published var morningBriefDismissedDay: String?

    private let defaults: UserDefaults
    private let profileKey = "fq.pet.profile"
    private let entriesKey = "fq.pet.entries"
    private let sealsKey = "fq.pet.seals"
    private let slipsKey = "fq.pet.slips"
    private let briefDismissKey = "fq.pet.briefDismiss"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.profile = Self.load(PetProfile.self, from: defaults, key: profileKey) ?? .blank
        self.entries = Self.load([ActivityEntry].self, from: defaults, key: entriesKey) ?? []
        self.seals = Self.load([DaySeal].self, from: defaults, key: sealsKey) ?? []
        self.slips = Self.load([SlipEntry].self, from: defaults, key: slipsKey) ?? []
        self.morningBriefDismissedDay = defaults.string(forKey: briefDismissKey)
        self.today = DaySnapshot.empty(dayKey: Self.todayKey())
        refreshToday()
    }

    var mood: PetMood {
        let sealedBoost = todayIsSealed ? 12.0 : 0
        let slipPenalty = Double(todaysSlips().count) * 6
        return PetMood.from(vitality: min(100, max(8, today.vitality + sealedBoost - slipPenalty)))
    }

    var bloomProgress: Double { VitalityEngine.bloomProgress(vitality: today.vitality) }

    var wiltFactor: Double {
        let slipFactor = min(0.35, Double(todaysSlips().count) * 0.08)
        return min(1, VitalityEngine.wiltFactor(vitality: today.vitality) + slipFactor + (todayIsSealed ? 0 : 0.08))
    }

    var stepProgress: Double {
        let goal = max(1, profile.dailyStepGoal)
        return min(1, Double(today.steps) / Double(goal))
    }

    var todayIsSealed: Bool {
        seals.contains { $0.dayKey == Self.todayKey() }
    }

    var todaySeal: DaySeal? {
        seals.first { $0.dayKey == Self.todayKey() }
    }

    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())

        while true {
            let key = ActivityEntry.dayFormatter.string(from: cursor)
            let sealed = seals.contains { $0.dayKey == key }
            let snapshot = snapshot(for: key)
            if sealed || snapshot.vitality >= 50 || snapshot.steps >= max(1000, profile.dailyStepGoal / 4) {
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
            return snapshot(for: ActivityEntry.dayFormatter.string(from: date))
        }.reversed()
    }

    var quests: [CareQuest] {
        [
            CareQuest(
                id: "steps",
                title: "Feed the stem",
                detail: "Log steps toward today's seal-worthy goal",
                symbolName: "figure.walk",
                target: profile.dailyStepGoal,
                progress: today.steps,
                kind: .steps
            ),
            CareQuest(
                id: "walk",
                title: "Quiet stroll",
                detail: "Park focused walk minutes before seal",
                symbolName: "timer",
                target: 30,
                progress: today.walkMinutes,
                kind: .walkMinutes
            ),
            CareQuest(
                id: "water",
                title: "Root sip",
                detail: "Track water glasses manually",
                symbolName: "drop.fill",
                target: 6,
                progress: today.water,
                kind: .water
            ),
            CareQuest(
                id: "stretch",
                title: "Stem reset",
                detail: "Stretch minutes keep the companion limber",
                symbolName: "figure.flexibility",
                target: 10,
                progress: today.stretchMinutes,
                kind: .stretch
            )
        ]
    }

    var morningBrief: MorningBrief? {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else { return nil }
        let key = ActivityEntry.dayFormatter.string(from: yesterday)
        guard let seal = seals.first(where: { $0.dayKey == key }) else { return nil }
        if morningBriefDismissedDay == Self.todayKey() { return nil }
        return MorningBrief(
            fromDayKey: key,
            carryIntentions: seal.carryIntentions,
            residueNote: seal.residueNote,
            suggestedQuietHour: suggestedQuietHour(),
            hasSeal: true
        )
    }

    var slipRadar: [(kind: SlipKind, count: Int)] {
        let recent = slips.filter { entry in
            guard let date = ActivityEntry.dayFormatter.date(from: entry.dayKey) else { return false }
            return date >= Calendar.current.date(byAdding: .day, value: -13, to: Date())!
        }
        return SlipKind.allCases.map { kind in
            (kind, recent.filter { $0.kind == kind }.count)
        }.sorted { $0.count > $1.count }
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

    func addSlip(kind: SlipKind, note: String = "") {
        slips.insert(SlipEntry(kind: kind, note: note), at: 0)
        persistSlips()
        objectWillChange.send()
    }

    func sealDay(intentions: [CarryIntention], residueNote: String, residueTag: SlipKind?) {
        guard !todayIsSealed else { return }
        let limited = Array(intentions.prefix(3))
        let seal = DaySeal(
            dayKey: Self.todayKey(),
            carryIntentions: limited,
            residueNote: residueNote.trimmingCharacters(in: .whitespacesAndNewlines),
            residueTag: residueTag,
            sealedAt: Date()
        )
        seals.removeAll { $0.dayKey == seal.dayKey }
        seals.insert(seal, at: 0)
        persistSeals()
        if let residueTag {
            slips.insert(SlipEntry(kind: residueTag, note: residueNote), at: 0)
            persistSlips()
        }
        objectWillChange.send()
    }

    func dismissMorningBrief() {
        morningBriefDismissedDay = Self.todayKey()
        defaults.set(morningBriefDismissedDay, forKey: briefDismissKey)
    }

    func todaysEntries() -> [ActivityEntry] {
        let key = Self.todayKey()
        return entries.filter { $0.dayKey == key }
    }

    func todaysSlips() -> [SlipEntry] {
        let key = Self.todayKey()
        return slips.filter { $0.dayKey == key }
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

    func suggestedQuietHour() -> Int? {
        let walkEntries = entries.filter { $0.kind == .walkMinutes || $0.kind == .steps }
        guard walkEntries.count >= 3 else { return nil }
        var buckets = Array(repeating: 0, count: 24)
        let calendar = Calendar.current
        for entry in walkEntries {
            let hour = calendar.component(.hour, from: entry.createdAt)
            buckets[hour] += entry.amount
        }
        guard let maxValue = buckets.max(), maxValue > 0,
              let hour = buckets.firstIndex(of: maxValue) else { return nil }
        return hour
    }

    private func persistProfile() {
        persist(profile, key: profileKey)
    }

    private func persistEntries() {
        persist(entries, key: entriesKey)
    }

    private func persistSeals() {
        persist(seals, key: sealsKey)
    }

    private func persistSlips() {
        persist(slips, key: slipsKey)
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func todayKey() -> String {
        ActivityEntry.dayFormatter.string(from: Date())
    }

    private static func load<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
