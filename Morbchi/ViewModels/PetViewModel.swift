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
        addMagicXP(5)
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
        addMagicXP(5)
        save()
    }
    //sleep
    func sleep()
    {
        currentAction = "sleep"
        guard let stats, let pet else { return }
        Task
        {
            for _ in 1...15
            {
                try? await Task.sleep(for: .seconds(60))
                guard currentAction == "sleep" else { return }
                stats.set(\.energy, to: stats.energy + (50.0 / 15.0))
                save()
            }
            
            stats.set(\.health, to: stats.health + 5)
            addMagicXP(3)
            save()
            
        }

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
        addMagicXP(2)
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

    private func addMagicXP(_ amount: Int)
    {
        guard let pet else { return }
        pet.magicXP += amount
        pet.lastInteractedAt = .now
        checkMagicLevelUp()
    }

    private func checkMagicLevelUp()
    {
        guard let pet else { return }
        let xpNeeded = pet.magicLevel * 100
        if pet.magicXP >= xpNeeded
        {
            pet.magicXP -= xpNeeded
            pet.magicLevel += 1
            stats?.magicalMoodExpiry = Date().addingTimeInterval(3600)
        }
    }
    
    private func save()
    {
        if let stats { engine.recalculateMood(stats: stats) }
        checkAndShowThought()
        try? context?.save()
    }
}
