//
//  TimerViewModel.swift
//  CountDownDemo
//
//  Created by Tushar on 20/12/23.
//

import SwiftUI
import Combine
import BackgroundTasks

class TimerViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var timeRemaining: TimeInterval = 59
    @Published var isRunning = false
    @Published var timerValue: String = "60:00"
    private var backgroundTime: TimeInterval = 0
    // MARK: - Computed Properties

    var progress: Double {
        return 1.0 - (timeRemaining / 59.0)
    }

    // MARK: - Private Properties

    private var timer: Cancellable?
    private var cancellables: Set<AnyCancellable> = []
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var backgroundTaskRequest: BGAppRefreshTaskRequest?

    // MARK: - Timer Actions

    func start() {
        guard !isRunning else {
            pause()
            return
        }
        self.setNotification()
        doBeginBackgroundTask()
        func doBeginBackgroundTask() {
            // Begin a background task when the timer starts
            backgroundTask = UIApplication.shared.beginBackgroundTask {
                // Handle the expiration of the background task if needed
                print("Remaining Time:= \(self.timeRemaining)")
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
                doBeginBackgroundTask()
            }
        }

        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.01
                    DispatchQueue.main.async {
                        self.timerValue = String(format: "%.0f:%02d", self.timeRemaining, Int(self.timeRemaining.truncatingRemainder(dividingBy: 1) * 100))
                    }
                } else {
                    self.reset()
                }
                
            }
        isRunning = true
    }

    func pause() {
        timer?.cancel()
        isRunning = false
        self.cancelNotification(Identifiers: "timerNotifyBackgroud")
    }

    func reset() {
        timeRemaining = 59
        isRunning = false
        timer?.cancel()
        self.timerValue = "60:00"
        self.cancelNotification(Identifiers: "timerNotifyBackgroud")
    }

    // MARK: - Background Task Handling
    func scheduleNextTask() {
        backgroundTaskRequest = BGAppRefreshTaskRequest(identifier: "com.bg.task")
        backgroundTaskRequest!.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Reschedule after 5 minutes
        do {
            try BGTaskScheduler.shared.submit(backgroundTaskRequest!)
        } catch {
            print("Error rescheduling task: \(error)")
        }
    }


    // MARK: - Notification Handling
    
    func setNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        content.body = "Your timer has finished!"
        self.timerValue = "60:00"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "timerNotifyBackgroud", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
        
        
        // End the background task after the notification is delivered
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = .invalid
    }
    func cancelNotification(Identifiers:String){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers])


    }
    func adjustTimeForForeground() {
         let currentTime = Date().timeIntervalSinceReferenceDate
         let timeInBackground = currentTime - backgroundTime

         // Subtract the time spent in the background from timeRemaining
         timeRemaining -= timeInBackground
         if timeRemaining < 0 {
             timeRemaining = 0
         }
     }

     func saveBackgroundTime() {
         // Save the current time when entering the background
         backgroundTime = Date().timeIntervalSinceReferenceDate
     }

}
