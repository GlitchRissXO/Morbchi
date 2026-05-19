import Foundation
import Combine

// Drives all passive stat drain and mood recalculation.
// Call start() on app launch; it ticks every 60 seconds.
@MainActor
final class PetEngine: ObservableObject
{
    static let shared = PetEngine()

    private var timer: AnyCancellable?

    // Drain rates per tick (per minute). Tune these during playtesting.
    private enum DrainRate
    {
        static let hunger:      Double = 0.5
        static let happiness:   Double = 0.3
        static let energy:      Double = 0.2
        static let cleanliness: Double = 0.15
        static let social:      Double = 0.25
    }

    func start(for stats: PetStats)
    {
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick(stats: stats)
            }
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
        stats.lastUpdated = .now
        recalculateMood(stats: stats)
    }

    private func recalculateMood(stats: PetStats)
    {
        switch true
        {
        case stats.health < 20:          stats.mood = .sick
        case stats.hunger < 20:          stats.mood = .hungry
        case stats.energy < 20:          stats.mood = .sleepy
        case stats.social < 20:          stats.mood = .lonely
        case stats.happiness < 20:       stats.mood = .sad
        case stats.magic > 80:           stats.mood = .magical
        case stats.happiness > 80 && stats.energy > 60: stats.mood = .excited
        case stats.happiness > 60:       stats.mood = .happy
        default:                         stats.mood = .curious
        }
    }
}
