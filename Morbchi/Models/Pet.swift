import Foundation
import SwiftData

@Model
final class Pet
{
    var name: String
    var personality: Personality
    var petType: PetType
    var lifeStage: LifeStage
    var xp: Int
    var level: Int
    var coins: Int
    var createdAt: Date
    var lastInteractedAt: Date

    @Relationship(deleteRule: .cascade) var stats: PetStats?

    init(name: String, personality: Personality, petType: PetType)
    {
        self.name = name
        self.personality = personality
        self.petType = petType
        self.lifeStage = .egg
        self.xp = 0
        self.level = 1
        self.coins = 10
        self.createdAt = .now
        self.lastInteractedAt = .now
    }
}

enum Personality: String, Codable, CaseIterable
{
    // Order matches the left-to-right layout on the onboarding personality screen
    case mischievous = "Mischievous"
    case dramatic    = "Dramatic"
    case wild        = "Wild"
    case sage        = "Sage"
    case gentle      = "Gentle"
    
    // Description of the personality.
        var description: String
        {
            switch self
            {
            case .mischievous: return "playful & teasing"
            case .dramatic:    return "theatrical & bold"
            case .wild:        return "energetic & chaotic"
            case .sage:        return "wise & cryptic"
            case .gentle:      return "soft & warm"
            }
        }
}

enum LifeStage: String, Codable, CaseIterable
{
    case egg      = "Egg"
    case sprout   = "Sprout"
    case wisp     = "Wisp"
    case briar    = "Briar"
    case shade    = "Shade"
    case familiar = "Familiar"
    case warden   = "Warden"
    case specter  = "Specter"
    case elder    = "Elder"
    case archmage = "Archmage"
    case ascended = "Ascended"
}

// The species of the pet, chosen during onboarding
enum PetType: String, Codable, CaseIterable
{
    case rabbit = "Rabbit"
    case cat    = "Cat"
    case fox    = "Fox"
    case snake  = "Snake"
    case koala  = "Koala"
}
