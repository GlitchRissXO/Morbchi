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
        
        //MARK: Coffee Break
        
        // Morning
        let lastMorning = UserDefaults.standard.object(forKey: "lastCoffeeMorning") as? Date
        let shownMorningToday = lastMorning.map { calendar.startOfDay(for: $0) == today } ?? false

        let inMorningWindow = (hour == 9 && minute >= 45) || (hour == 10 && minute <= 15)

        if inMorningWindow && !shownMorningToday
        {
            UserDefaults.standard.set(now, forKey: "lastCoffeeMorning")
            onNudge?(.coffee)
            return
        }
        
        //Afternoon
        let lastAfternoon = UserDefaults.standard.object(forKey: "lastCoffeeAfternoon") as? Date
        let shownAfternoonToday = lastAfternoon.map {calendar.startOfDay(for: $0) == today } ?? false
        
        let inAfternoonWindow = (hour == 14 && minute >= 45) || (hour == 15 && minute <= 15)
        
        if inAfternoonWindow && !shownAfternoonToday
        {
            UserDefaults.standard.set(now, forKey: "lastCoffeeAfternoon")
            onNudge?(.coffee)
            return
        }
        
        
        // MARK: Water Break
        let lastWater = UserDefaults.standard.object(forKey: "lastWaterNudge") as? Date ?? Date.distantPast
        
        if now.timeIntervalSince(lastWater) >= 3600
        {
            UserDefaults.standard.set(now, forKey: "lastWaterNudge")
            onNudge?(.water)
            return
        }
        
        // MARK: Time Break
        
        let lastBreak = UserDefaults.standard.object(forKey: "lastBreakNudge") as? Date ?? Date.distantPast
        
        if now.timeIntervalSince(lastBreak) >= 9000
        {
            UserDefaults.standard.set(now, forKey: "lastBreakNudge")
            onNudge?(.breakTime)
            return
        }
    }
    
}
