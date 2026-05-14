import SwiftUI
import SwiftData

@main
struct MorbchiApp: App
{
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let container: ModelContainer

    init()
    {
        do
        {
            container = try ModelContainer(for: Pet.self, PetStats.self)
        } catch
        {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
        appDelegate.modelContainer = container
    }

    var body: some Scene
    {
        // Hidden main window — the pet lives in a floating NSPanel, not a standard window
        Settings {
            EmptyView()
        }
        .modelContainer(container)
    }
}
