import AppKit
import SwiftData

class AppDelegate: NSObject, NSApplicationDelegate
{
    var modelContainer: ModelContainer?
    var petViewModel: PetViewModel?  // SwiftData needed
    var petWindowController: PetWindowController? //SwiftData needed
    
    // Called by macOS once the app has fully loaded and is ready to run.
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        let viewModel = PetViewModel() //create the view model
        petViewModel = viewModel
        
        if let container = modelContainer //load the pet
        {
            let context = ModelContext(container)
            viewModel.load(from: context)
        }
        
        let controller = PetWindowController(viewModel: viewModel) // create window controller
        petWindowController = controller
        controller.show() //floating pet panel on screen
    }
}
