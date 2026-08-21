import Foundation
import SwiftData
import Combine

@MainActor
final class PetViewModel: ObservableObject
{
    @Published var pet: Pet?
    @Published var currentAction: String?
    @Published var currentThought: String?
    private var context: ModelContext?
    @Published var stats: PetStats?

    private let engine = PetEngine.shared
    private let wellnessEngine = WellnessEngine.shared

    func load(from context: ModelContext)
    {
        self.context = context
        let descriptor = FetchDescriptor<Pet>()
        pet = try? context.fetch(descriptor).first
        stats = pet?.stats

        if let stats
        {
            engine.start(for: stats, onSave: { [weak self] in
                self?.save()})
            
            wellnessEngine.start { [weak self] nudge in
            self?.showWellnessNudge(nudge)}
        }
        
    }

    // MARK: - Care Actions
    //Feed
    func feed(amount: Double = 20)
    {
        currentAction = "feed"
        Task { try? await Task.sleep(for: .seconds(2)); currentAction = nil}
        guard let stats else { return }
        stats.set(\.hunger, to: stats.hunger + amount)
        stats.set(\.happiness, to: stats.happiness + 5)
        stats.set(\.health, to: stats.health + 2)
        addXP(5)
        save()
        
    }
    //bath
    func bathe()
    {
        currentAction = "bath"
        Task { try? await Task.sleep(for: .seconds(2)); currentAction = nil}
        guard let stats else { return }
        stats.set(\.cleanliness, to: 100)
        stats.set(\.happiness, to: stats.happiness + 5)
        stats.set(\.health, to: stats.health + 40)
        addXP(5)
        save()
    }
    //sleep
    func sleep()
    {
        currentAction = "sleep"
        guard let stats, let pet else { return }
        stats.set(\.energy, to: stats.energy + 50)
        stats.set(\.health, to: stats.health + 5)
        addXP(3)
        save()

        //Dream Thoughts
        
        let thoughts = PetDialogue.dreamThoughts(for: pet.personality)

        Task { try? await Task.sleep(for: .seconds(60 * 15)); currentAction = nil }

        Task
        {
            let count = Int.random(in: 1...2)

            try? await Task.sleep(for: .seconds(Double.random(in: 120...420)))
            guard currentAction == "sleep" else { return }
            currentThought = thoughts.randomElement()
            try? await Task.sleep(for: .seconds(20))
            currentThought = nil

            guard count == 2 else { return }

            try? await Task.sleep(for: .seconds(Double.random(in: 120...240)))
            guard currentAction == "sleep" else { return }
            currentThought = thoughts.randomElement()
            try? await Task.sleep(for: .seconds(20))
            currentThought = nil
        }
    }

    //cuddle
    
    func cuddle()
    {
        currentAction = "pet"
        Task { try? await Task.sleep(for: .seconds(2)); currentAction = nil}
        guard let stats else { return }
        stats.set(\.happiness, to: stats.happiness + 10)
        stats.set(\.social, to: stats.social + 10)
        stats.set(\.health, to: stats.health + 2)
        addXP(2)
        save()
    }
    
    func showWellnessNudge(_ nudge: WellnessNudge)
    {
        if currentAction == "sleep" { return }
        guard let pet else { return }
        
        switch nudge
        {
        case .coffee: currentAction = "coffee"
        case .water: currentAction = "water"
        case .breakTime: currentAction = "break"
        }
        
        currentThought = PetDialogue.wellnessMessage(for: nudge, personality: pet.personality)
        Task { try? await Task.sleep(for: .seconds(60)); currentAction = nil; currentThought = nil}
    }
    
    // MARK: Thoughts low stats.
    func checkAndShowThought()
    {
        if currentAction == "sleep" { currentThought = nil; return }
        guard let stats, let pet else { return }
        
        if stats.health < 20
        {
            currentThought = PetDialogue.message(for: .sick, personality: pet.personality)
        }
        else if stats.hunger < 30
        {
            currentThought = PetDialogue.message(for: .hunger, personality: pet.personality)
        }
        else if stats.energy < 30
        {
            currentThought = PetDialogue.message(for: .energy, personality: pet.personality)
        }
        else if stats.happiness < 30
        {
            currentThought = PetDialogue.message(for: .happiness, personality: pet.personality)
        }
        else if stats.cleanliness < 30
        {
            currentThought = PetDialogue.message(for: .cleanliness, personality: pet.personality)
        }
        else
        {
            currentThought = nil
        }
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
    
    private func save()
    {
        if let stats { engine.recalculateMood(stats: stats) }
        checkAndShowThought()
        try? context?.save()
    }
}
