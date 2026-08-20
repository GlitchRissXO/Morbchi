// time based wellness nudges reminding the user to get coffee, drink water, and take breaks
import Foundation
import Combine

@MainActor

final class WellnessEngine
{
    static let shared = WellnessEngine()
    private init() {}
    
    private var timer: AnyCancellable?
    var onNudge: ((WellnessNudge) -> Void)?
    
    func start(onNudge: @escaping (WellnessNudge) -> Void)
    {
        self.onNudge = onNudge
           timer = Timer.publish(every: 300, on: .main, in: .common)
               .autoconnect()
               .sink { [weak self] _ in self?.check() }
    }

    func stop()
    {
        timer?.cancel()
    }
    
    private func check()
    {
        //Date & Time
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let today = calendar.startOfDay(for: now)
        
        //Coffee Morning Check
        let lastMorning = UserDefaults.standard.object(forKey: "lastCoffeeMorning") as? Date
        let shownMorningToday = lastMorning.map { calendar.startOfDay(for: $0) == today } ?? false

        let inMorningWindow = (hour == 9 && minute >= 45) || (hour == 10 && minute <= 15)

        if inMorningWindow && !shownMorningToday
        {
            UserDefaults.standard.set(now, forKey: "lastCoffeeMorning")
            onNudge?(.coffee)
            return
        }
        
        //Coffee Afternoon Check
        let lastAfternoon = UserDefaults.standard.object(forKey: "lastCoffeeAfternoon") as? Date
        let shownAfternoonToday = lastAfternoon.map {calendar.startOfDay(for: $0) == today } ?? false
        
        let inAfternoonWindow = (hour == 14 && minute >= 45) || (hour == 15 && minute <= 15)
        
        if inAfternoonWindow && !shownAfternoonToday
        {
            UserDefaults.standard.set(now, forKey: "lastCoffeeAfternoon")
            onNudge?(.coffee)
            return
        }
        
    }
    
}
