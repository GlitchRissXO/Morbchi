import Foundation
import SwiftData

@Model
final class Pet
{
    var name: String
    var personality: Personality
    var petType: PetType
    var magicXP: Int
    var magicLevel: Int
    var coins: Int
    var createdAt: Date
    var lastInteractedAt: Date

    @Relationship(deleteRule: .cascade) var stats: PetStats?

    init(name: String, personality: Personality, petType: PetType)
    {
        self.name = name
        self.personality = personality
        self.petType = petType
        self.magicXP = 0
        self.magicLevel = 1
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

// The species of the pet, chosen during onboarding
enum PetType: String, Codable, CaseIterable
{
    case rabbit = "Rabbit"
    case cat    = "Cat"
    case fox    = "Fox"
    case snake  = "Snake"
    case koala  = "Koala"
}
