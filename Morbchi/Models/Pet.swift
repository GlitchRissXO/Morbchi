import Foundation
import SwiftData

@Model
final class Pet
{
    var name: String
    var personality: Personality
    var lifeStage: LifeStage
    var xp: Int
    var level: Int
    var coins: Int
    var createdAt: Date
    var lastInteractedAt: Date

    @Relationship(deleteRule: .cascade) var stats: PetStats?

    init(name: String, personality: Personality)
    {
        self.name = name
        self.personality = personality
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
    case mischievous = "Mischievous"
    case gentle      = "Gentle"
    case sage        = "Sage"
    case wild        = "Wild"
    case dramatic    = "Dramatic"
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
