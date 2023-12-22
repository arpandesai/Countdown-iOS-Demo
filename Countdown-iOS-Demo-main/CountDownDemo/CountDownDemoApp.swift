//
//  CountDownDemoApp.swift
//  CountDownDemo
//
//  Created by Tushar on 20/12/23.
//

import SwiftUI
import BackgroundTasks

@main
struct CountDownDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: TimerViewModel())
        }
    }
    
    
}
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        self.requestNotificationPermission()
        let viewModel = TimerViewModel()
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bg.task", using: nil) { task in
            print("Registered")
            viewModel.scheduleNextTask()
        }
        
        return true
    }
    func requestNotificationPermission() {
       UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
           if granted {
               print("Notification permission granted")
           } else {
               print("Notification permission denied")
           }
       }
   }
   
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Implement UNUserNotificationCenterDelegate methods if needed
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
    }
}


