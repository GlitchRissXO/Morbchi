import SwiftUI

// The floating pet that lives on the desktop.
// Hosted inside a transparent, borderless NSPanel.
struct DesktopPetView: View {
    @ObservedObject var viewModel: PetViewModel

    var body: some View
    {
        ZStack
        {
            // Placeholder sprite — replace with actual pet artwork
            VStack(spacing: Theme.Spacing.xs)
            {
                Text(moodEmoji)
                    .font(.system(size: 64))
                    .shadow(color: Theme.Color.accentCool.opacity(0.6), radius: 12)

                if let mood = viewModel.stats?.mood
                {
                    Text(mood.displayName)
                        .font(Theme.Font.flavor(11))
                        .foregroundStyle(Theme.Color.textMuted)
                }
            }
            .padding(Theme.Spacing.sm)
        }
        .background(Color.clear)
        .contextMenu { contextMenuItems }
    }

    private var moodEmoji: String
    {
        switch viewModel.stats?.mood
        {
        case .happy:    return "Happy"
        case .excited:  return "Excited"
        case .sleepy:   return "Sleepy"
        case .hungry:   return "Hungry"
        case .sad:      return "Sad"
        case .sick:     return "Sick"
        case .playful:  return "Playful"
        case .curious:  return "Curious"
        case .grumpy:   return "Grumpy"
        case .lonely:   return "Lonely"
        case .magical:  return "Magical"
        case .ascended: return "Star"
        case nil:       return "Moon"
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
        Button("Quit Morbchi", role: .destructive) { NSApp.terminate(nil) }
    }
}
