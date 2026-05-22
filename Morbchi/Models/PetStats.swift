import Foundation
import SwiftData

@Model
final class PetStats
{
    var hunger:      Double  // 0–100, drains fastest
    var happiness:   Double
    var energy:      Double
    var health:      Double
    var cleanliness: Double
    var social:      Double
    var magic:       Double  // grows with leveling
    var knowledge:   Double  // grows from games/puzzles

    var mood: Mood
    var lastUpdated: Date

    init()
    {
        self.hunger      = 80
        self.happiness   = 80
        self.energy      = 100
        self.health      = 100
        self.cleanliness = 100
        self.social      = 80
        self.magic       = 10
        self.knowledge   = 10
        self.mood        = .happy
        self.lastUpdated = .now
    }

    // Clamp a stat value to 0–100
    func set(_ keyPath: ReferenceWritableKeyPath<PetStats, Double>, to value: Double)
    {
        self[keyPath: keyPath] = min(100, max(0, value))
    }
}

enum Mood: String, Codable, CaseIterable {
    case happy, excited, sleepy, hungry, sad, sick
    case playful, curious, grumpy, magical, ascended

    var displayName: String { rawValue.capitalized }
}
