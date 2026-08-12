//Simple Pet Thoughts

import Foundation

enum LowStat
{
    case hunger, energy, happiness, cleanliness
}

struct PetDialogue
{
    static func message(for stat: LowStat, personality: Personality) -> String
    {
        switch (stat, personality)
        {
        //Hunger
        case (.hunger, .mischievous):
            return "if I don't eat soon i'm chewing your cables..."
        case (.hunger, .dramatic):
            return "I am WASTING AWAYYYY. Sustenance. Now."
        case (.hunger, .wild):
            return "FOOD FOOD FOOD FOOD FOOD"
        case (.hunger, .sage):
            return "The body hungers as the spirit yearns..."
        case (.hunger, .gentle):
            return "Um... I hate to bother you, but I'm a little hungry?"
        
        //Energy
        case (.energy, .mischievous):
            return "Getting tired..too tired to cause chaos... for now."
        case (.energy, .dramatic):
            return "YAWNNN...I am utterly EXHAUSTED. I must rest immediately."
        case (.energy, .wild):
            return "can't... stop... moving... okay maybe just a tiny nap."
        case (.energy, .sage):
            return "Even the stars must rest before they shine again..."
        case (.energy, .gentle):
            return "I'm getting a little sleepy. A nap is much needed."
            
        //Happiness
        case (.happiness, .mischievous):
            return "I'm bored. Come pet me before I get annoying."
        case (.happiness, .dramatic):
            return "I have never felt so alone in all my days..."
        case (.happiness, .wild):
            return "PET ME PET ME PET ME PET ME"
        case (.happiness, .sage):
            return "The wisest soul still needs companionship..."
        case (.happiness, .gentle):
            return "I could really use a hug right now."
            
        //Cleanliness
        case (.cleanliness, .mischievous):
            return "Wanna hug?? I smell terrible and I love it... but maybe a bath wouldn't hurt."
        case (.cleanliness, .dramatic):
            return "EWW..GOD DO YOU SMELL THAT....The STENCH! I cannot go on like this!"
        case (.cleanliness, .wild):
            return "I rolled in somethign but dirt is just outdoor glitter, right?"
        case (.cleanliness, .sage):
            return "A clear body brings a clear mind..."
        case (.cleanliness, .gentle):
            return "Um...I think I might need a bath..."
            
        }
    }
}
