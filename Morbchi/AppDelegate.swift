import AppKit
import SwiftData
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate
{
    var modelContainer: ModelContainer?
    var petViewModel: PetViewModel?
    var petWindowController: PetWindowController?
    var onboardingWindow: NSWindow?
    var menuBarController: MenuBarController?
    var statsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification)
    {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Pet>()
        let existingPet = try? context.fetch(descriptor).first

        let viewModel = PetViewModel()
        petViewModel = viewModel

        // Listen for the open stats window notification from anywhere in the app
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showStatsWindow),
            name: .openStatsWindow,
            object: nil
        )

        if existingPet == nil {
            showOnboarding(context: context, viewModel: viewModel)
        } else {
            viewModel.load(from: context)
            showPetWindow(viewModel: viewModel)
        }
    }

    func showOnboarding(context: ModelContext, viewModel: PetViewModel)
    {
        let view = OnboardingView { [weak self] name, personality in
            let newPet = Pet(name: name, personality: personality)
            let newStats = PetStats()
            newPet.stats = newStats
            context.insert(newPet)
            context.insert(newStats)
            try? context.save()

            viewModel.load(from: context)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.onboardingWindow?.close()
                self?.onboardingWindow = nil
                self?.showPetWindow(viewModel: viewModel)
            }
        }

        let hosting = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 560),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Welcome to Morbchi"
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        onboardingWindow = window
    }

    func showPetWindow(viewModel: PetViewModel)
    {
        let controller = PetWindowController(viewModel: viewModel)
        petWindowController = controller
        controller.show()
        menuBarController = MenuBarController(viewModel: viewModel)
    }

    @objc func showStatsWindow()
    {
        // If already open, just bring it forward
        if let existing = statsWindow {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        guard let viewModel = petViewModel else { return }

        let view = MenuBarPopoverView(viewModel: viewModel)
        let hosting = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Morbchi"
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.center()
        window.makeKeyAndOrderFront(nil)
        statsWindow = window
    }
}

extension Notification.Name
{
    // Posted by DesktopPetView when the user taps "Open Stats"
    static let openStatsWindow = Notification.Name("openStatsWindow")
}
