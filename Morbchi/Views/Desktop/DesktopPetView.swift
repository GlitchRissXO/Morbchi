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
                Image(moodImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                if let mood = viewModel.stats?.mood
                {
                    Text(mood.displayName)
                        .font(Theme.Font.heading(16))
                        .foregroundStyle(Theme.Color.textMuted)
                }
            }
            .padding(Theme.Spacing.sm)
        }
        .background(Color.clear)
        .contextMenu { contextMenuItems }
    }

    private var moodImage: String
    {
        switch viewModel.stats?.mood
        {
        case .happy:    return "pet_happy"
        case .excited:  return "pet_excited"
        case .sleepy:   return "pet_sleepy"
        case .hungry:   return "pet_hungry"
        case .sad:      return "pet_sad"
        case .sick:     return "pet_sick"
        case .playful:  return "pet_playful"
        case .curious:  return "pet_curious"
        case .grumpy:   return "pet_grumpy"
        case .magical:  return "pet_magical"
        case .ascended: return "pet_ascended"
        case nil:       return "pet_idle"
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
