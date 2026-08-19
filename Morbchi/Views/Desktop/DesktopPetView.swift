import SwiftUI

// The floating pet that lives on the desktop.
// Hosted inside a transparent, borderless NSPanel.
struct DesktopPetView: View {
    @ObservedObject var viewModel: PetViewModel

    // Controls the idle bob animation
    @State private var isAnimating = false

    var body: some View
    {
        ZStack
        {

            // Pet + speech bubble + mood badge
            VStack(spacing: Theme.Spacing.xs)
            {
                if let thought = viewModel.currentThought, viewModel.currentAction != "sleep"
                {
                    ThoughtBubbleView(text: thought)
                }

                Image(petSprite)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .overlay(alignment: .topTrailing) {
                        if let thought = viewModel.currentThought, viewModel.currentAction == "sleep"
                        {
                            DreamBubbleView(text: thought)
                                .offset(x: 150, y: -150)
                        }
                    }
                    .offset(y: isAnimating ? -8 : 0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear { isAnimating = true }

                if let mood = viewModel.stats?.mood
                {
                    MoodBadgeView(mood: mood)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .contextMenu { contextMenuItems }
    }

    // Returns the correct sprite for the pet's type.
    // Once mood-specific sprites are designed, this will map mood + type together.
    private var petSprite: String
    {
        let type = viewModel.pet?.petType.rawValue.lowercased() ?? "cat"
        
        if let action = viewModel.currentAction
        {
            return "\(type)_\(action)"
        }
        
        if let stats = viewModel.stats
        {
            if stats.health < 20        { return "\(type)_sick" }
            if stats.cleanliness < 30   { return "\(type)_dirty" }
        }
        
        switch viewModel.stats?.mood
        {
        case .excited:  return "\(type)_excited"
        case .magical:  return "\(type)_magical"
        case .sleepy:   return "\(type)_tired"
        case .hungry:   return "\(type)_hungry"
        case .sad:      return "\(type)_sad"
        case .sick:     return "\(type)_sick"
        case .curious:  return "\(type)_curious"
        default:        return "\(type)_idle"
        }
    }

    @ViewBuilder
    private var contextMenuItems: some View
    {
        Button("Feed")  { viewModel.feed() }
        Button("Pet")   { viewModel.cuddle() }
        Button("Bathe") { viewModel.bathe() }
        Button("Sleep") { viewModel.sleep() }
        Divider()
        Button("Open Room") { /* TODO: open Room window */ }
        Button("Open Stats") {
            NotificationCenter.default.post(name: .openStatsWindow, object: nil)
        }
        Button("Quit Morbchi", role: .destructive) { NSApp.terminate(nil) }
    }
}
