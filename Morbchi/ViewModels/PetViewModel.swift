import Foundation
import SwiftData
import Combine

@MainActor
final class PetViewModel: ObservableObject
{
    @Published var pet: Pet?
    @Published var stats: PetStats?

    private let engine = PetEngine.shared

    func load(from context: ModelContext)
    {
        let descriptor = FetchDescriptor<Pet>()
        pet = try? context.fetch(descriptor).first
        stats = pet?.stats

        if let stats
        {
            engine.start(for: stats)
        }
    }

    // MARK: - Care Actions

    func feed(amount: Double = 20)
    {
        guard let stats else { return }
        stats.set(\.hunger, to: stats.hunger + amount)
        stats.set(\.happiness, to: stats.happiness + 5)
        addXP(5)
    }

    func bathe()
    {
        guard let stats else { return }
        stats.set(\.cleanliness, to: 100)
        stats.set(\.happiness, to: stats.happiness + 5)
        addXP(5)
    }

    func sleep()
    {
        guard let stats else { return }
        stats.set(\.energy, to: 100)
        addXP(3)
    }

    func cuddle()
    {
        guard let stats else { return }
        stats.set(\.happiness, to: stats.happiness + 10)
        stats.set(\.social, to: stats.social + 10)
        addXP(2)
    }

    // MARK: - Progression

    private func addXP(_ amount: Int)
    {
        guard let pet else { return }
        pet.xp += amount
        pet.lastInteractedAt = .now
        checkLevelUp()
    }

    private func checkLevelUp()
    {
        guard let pet else { return }
        let xpNeeded = pet.level * 100
        if pet.xp >= xpNeeded
        {
            pet.xp -= xpNeeded
            pet.level += 1
            stats?.set(\.magic, to: (stats?.magic ?? 0) + 5)
        }
    }
}
