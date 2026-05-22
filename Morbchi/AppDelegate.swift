import AppKit
import SwiftData
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate
{
    var modelContainer: ModelContainer?
    var petViewModel: PetViewModel?
    var petWindowController: PetWindowController?
    var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification)
    {
        guard let container = modelContainer else { return }
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Pet>()
        let existingPet = try? context.fetch(descriptor).first

        let viewModel = PetViewModel()
        petViewModel = viewModel

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
    }
}
