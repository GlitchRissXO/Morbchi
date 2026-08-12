import AppKit
import SwiftUI
import SwiftData

// Creates and manages the floating, transparent, click-through-background pet window.
final class PetWindowController: NSWindowController
{
    private let viewModel: PetViewModel

    init(viewModel: PetViewModel)
    {
        self.viewModel = viewModel

        let panel = NSPanel(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 300),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false)
        panel.level            = .floating
        panel.isOpaque         = false
        panel.backgroundColor  = .clear
        panel.hasShadow        = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary]
        panel.isMovableByWindowBackground = true

        let petView = DesktopPetView(viewModel: viewModel)
        panel.contentView = NSHostingView(rootView: petView)

        super.init(window: panel)
        restorePosition()
    }

    required init?(coder: NSCoder) { fatalError("not used")
    }

    func show() {
        window?.orderFrontRegardless()
    }

    // MARK: - Position persistence

    func savePosition()
    {
        guard let origin = window?.frame.origin else { return }
        UserDefaults.standard.set(NSStringFromPoint(origin), forKey: "petWindowOrigin")
    }

    private func restorePosition()
    {
        if let saved = UserDefaults.standard.string(forKey: "petWindowOrigin")
        {
            let origin = NSPointFromString(saved)
            window?.setFrameOrigin(origin)
        }
    }
}
