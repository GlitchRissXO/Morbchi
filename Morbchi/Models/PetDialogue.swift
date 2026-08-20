//Simple Pet Thoughts

import Foundation

enum LowStat {case hunger, energy, happiness, cleanliness, sick}

enum WellnessNudge { case coffee, water, breakTime }

struct PetDialogue
{
    // MARK: - Low Stats Messages
    static func message(for stat: LowStat, personality: Personality) -> String
    {
        switch (stat, personality)
        {
        //Hunger
        case (.hunger, .mischievous):
            return "If I don't eat soon i'm chewing your cables..."
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
            return "Can't... stop... moving... okay maybe just a tiny nap."
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

        //Sick
        case (.sick, .mischievous):
            return "I feel terrible... and I'm blaming you entirely."
        case (.sick, .dramatic):
            return "I am DYING. This is the end. Goodbye, cruel world."
        case (.sick, .wild):
            return "Something is wrong. I don't like it. FIX IT NOW."
        case (.sick, .sage):
            return "The body speaks when the spirit has been ignored too long..."
        case (.sick, .gentle):
            return "I don't feel very well... I think I need some help."
            
        }
    }
    
    // MARK: - Dream Thoughts
    static func dreamThoughts(for personality: Personality) -> [String]
    {
        switch personality
        {
        case .mischievous:
            return [
                
                "...stealing all the snacks and no one can stop me...",
                "...chasing something... not sure what... but winning...",
                "...the world is made of yarn and I own all of it...",
                "...getting away with it again...",
                "...hiding everything and watching them look for it...",
                "...being chaotic feels so good even in dreams..."
            ]
        case .dramatic:
            return [
                
                "...being the star of the show... obviously...",
                "...everyone is gasping as I enter the room...",
                "...a standing ovation... just for existing...",
                "...being so beautiful it's making everyone cry...",
                "...the whole world is watching as I take my bow...",
                "...even in dreams I am the main character..."
            ]
        case .wild:
            return [
                
                "...running... running so fast... wheeeee...",
                "...everything is moving really fast and I love it...",
                "...there are snacks EVERYWHERE...",
                "...flying but also rolling... both at once...",
                "...so many things to chase... so many...",
                "...the dream is loud and I am louder..."
            ]
        case .sage:
            return [
                
                "...the moon is speaking and I understand...",
                "...all things return to where they began...",
                "...dreaming of the dream inside the dream...",
                "...the stars are just eyes that never close...",
                "...time moves differently when you are still...",
                "...even sleep holds its own kind of wisdom..."
            ]
        case .gentle:
            return [
                
                "...everything is warm and soft and very nice...",
                "...someone is making tea and the whole place smells like honey...",
                "...the flowers are singing very quietly...",
                "...so cozy... don't want to wake up...",
                "...it feels like a big warm hug...",
                "...someone is humming and it is the nicest sound...mhmmhhm"
            ]
        }
    }
        // MARK: - Wellness Messages
        static func wellnessMessage(for nudge: WellnessNudge, personality: Personality) -> String
        {
            switch (nudge, personality)
            {
                // Coffee
            case (.coffee, .mischievous):
                return "No coffee yet?? Bold choice. Terrible, but bold."
            case (.coffee, .dramatic):
                return "I NEED you to go get a coffee. For both our sakes."
            case (.coffee, .wild):
                return "COFFEE TIME. GO. NOW. PLEASEEEE."
            case (.coffee, .sage):
                return "Coffee breaks are... sacred. Do not skip it."
            case (.coffee, .gentle):
                return "Hey... have you had your coffee yet? Just checking on you."
                
                // Water
            case (.water, .mischievous):
                return "Hydrate or I start causing problems. Your call."
            case (.water, .dramatic):
                return "You are WITHERING. Please. Drink some water."
            case (.water, .wild):
                return "WATER WATER WATER drink it NOW go!!"
            case (.water, .sage):
                return "The well within you runs low. Drink some water."
            case (.water, .gentle):
                return "Have you had some water recently? Please take care of yourself."
                
                //Break
            case (.breakTime, .mischievous):
                return "You've been sitting there for AGES. Get up. I'm embarrassed for you."
            case (.breakTime, .dramatic):
                return "You MUST step away. Your back is probably screaming at you."
            case (.breakTime, .wild):
                return "GET UP! MOVE, STRETCH, DO SOMETHING! ANYTHINGGGGG."
            case (.breakTime, .sage):
                return "Rest is not weakness. It is part of the work. Take a break."
            case (.breakTime, .gentle):
                return "You've been at it for a while. A little break would do you good."
                
        
        }
    }
}
