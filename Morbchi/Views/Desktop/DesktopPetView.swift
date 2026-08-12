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
            VStack(spacing: Theme.Spacing.xs)
            {
                Image(petSprite)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    // Gentle idle bob — floats up and back down on repeat
                    .offset(y: isAnimating ? -8 : 0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .onAppear { isAnimating = true }

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

    // Returns the correct sprite for the pet's type.
    // Once mood-specific sprites are designed, this will map mood + type together.
    private var petSprite: String
    {
        let type = viewModel.pet?.petType.rawValue.lowercased() ?? "cat"
        let action = viewModel.currentAction ?? "idle"
        return "\(type)_\(action)"
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
