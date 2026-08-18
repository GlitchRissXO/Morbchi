import Foundation
import Combine

// Drives all passive stat drain and mood recalculation.
// Call start() on app launch; it ticks every 60 seconds.
@MainActor
final class PetEngine: ObservableObject
{
    static let shared = PetEngine()

    private var timer: AnyCancellable?
    private var onSave: (() -> Void)?

    // Drain rates per tick (per minute). Tune these during playtesting.
    private enum DrainRate
    {
        static let hunger:      Double = 0.5
        static let happiness:   Double = 0.4
        static let energy:      Double = 0.3
        static let cleanliness: Double = 0.15
        static let social:      Double = 0.3
    }

    func start(for stats: PetStats, onSave: @escaping () -> Void)
    {
        timer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink
            { [weak self] _ in
                self?.tick(stats: stats)
            }
        self.onSave = onSave
    }

    func stop()
    {
        timer?.cancel()
    }

    private func tick(stats: PetStats)
    {
        stats.set(\.hunger,      to: stats.hunger      - DrainRate.hunger)
        stats.set(\.happiness,   to: stats.happiness   - DrainRate.happiness)
        stats.set(\.energy,      to: stats.energy      - DrainRate.energy)
        stats.set(\.cleanliness, to: stats.cleanliness - DrainRate.cleanliness)
        stats.set(\.social,      to: stats.social      - DrainRate.social)
        
        //Starving (hunger critically low)
        if stats.hunger < 15
        {
            stats.set(\.energy, to: stats.energy - 0.3)
            stats.set(\.happiness, to: stats.happiness - 0.3)
            stats.set(\.health, to: stats.health - 0.2)
        }
        
        //Exhausted (energy critically low)
        if stats.energy < 15
        {
            stats.set(\.health, to: stats.health - 0.2)
            stats.set(\.happiness, to: stats.happiness - 0.2)
        }
        
        //Dirty (cleanliness low)
        if stats.cleanliness < 30
        {
            stats.set(\.health, to: stats.health - 0.2)
            stats.set(\.happiness, to: stats.happiness - 0.2)
            stats.set(\.energy, to: stats.energy - 0.15)
        }
        
        // Positive health recovery when stats are high
        if stats.hunger > 70    { stats.set(\.health, to: stats.health + 0.1)}
        if stats.happiness > 70 {stats.set (\.health, to: stats.health + 0.1)}
        if stats.energy > 70 {stats.set (\.health, to: stats.health + 0.1)}
        
        stats.lastUpdated = .now
        recalculateMood(stats: stats)
        onSave?()
    }

    func recalculateMood(stats: PetStats)
    {
        switch true
        {
        case stats.health < 20:          stats.mood = .sick
        case stats.hunger < 30:          stats.mood = .hungry
        case stats.energy < 30:          stats.mood = .sleepy
        case stats.social < 30:          stats.mood = .sad
        case stats.happiness < 30:       stats.mood = .sad
        case stats.magic > 80:           stats.mood = .magical
        case stats.happiness > 80 && stats.energy > 60: stats.mood = .excited
        case stats.happiness > 60:       stats.mood = .happy
        default:                         stats.mood = .curious
        }
    }
}
