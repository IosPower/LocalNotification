//
//  AppDelegate.swift
//  LocalNotification
//
//  Created by Piyush Sinroja on 25/11/19.
//  Copyright © 2019 Piyush. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation
import AudioToolbox

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    var applicationbadge: Int = 0
    let requestIdentifier = "SampleRequest"
    
    var audioPlayer:AVAudioPlayer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("Granted!")
            } else {
                print("User has declined notification")
            }
        }
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.showPreviewsSetting {
            case .always :
                print("Always")
            case .whenAuthenticated :
                print("When unlocked")
            case .never :
                print("Never")
            }
        }
        // playSound()
        
        //        let date = Date().addingTimeInterval(5)
        //        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(playSound), userInfo: nil, repeats: false)
        //        RunLoop.main.add(timer, forMode: .common)
        
        return true
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    @objc func playSound() {
        guard let player = audioPlayer, player.isPlaying else { return
            playAudioFile(soundName: "iphone10")
        }
    }
    
    func playAudioFile(soundName: String)  {
        
        setupAudioSession()
        
        //vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                              nil,
                                              { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                                                print("callback", terminator: "") //todo
        },
                                              nil)
        
        guard let urlPath = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        let coinSound = URL(fileURLWithPath: urlPath)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:coinSound)
            audioPlayer!.prepareToPlay()
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.play()
        } catch (let error) {
            print(error)
            print("Error getting the audio file")
        }
    }
    
    func scheduleNotification(notificationType: String, timer: Int) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        
        content.title = notificationType
        content.body = "This is example how to create " + notificationType
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "iphone10.mp3"))
        content.badge = 1
        content.userInfo = ["customData": "fizzbuzz"]
        content.categoryIdentifier = categoryIdentifire
        
        //To Present image in notification
        if let path = Bundle.main.path(forResource: "monkey", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "sampleImage", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("attachment not found.")
            }
        }
        
        //        var dateComponents = DateComponents()
        //        dateComponents.hour = 10
        //        dateComponents.minute = 30
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        ///------------------------------------------------------------------------------/////
        // Specific date time
        //-----------------------------****-------------------------------
        // let date = Date(timeIntervalSinceNow: 3600)
        // let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        //let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
        //                                            repeats: false)
        
        //-----------------------------****-------------------------------
        
        // Daily
        //-----------------------------****-------------------------------
        
        //let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date) // for daily used 3600 second
        // let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        //-----------------------------****-------------------------------
        
        
        // Weekly
        //-----------------------------****-------------------------------
        
        // let triggerWeekly = Calendar.current.dateComponents([.weekday,hour,.minute,.second,], from: date)
        // let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
        
        //-----------------------------****-------------------------------
        
        // Swift
        //-----------------------------****-------------------------------
        
        //  Location: Trigger when a user enters or leaves a geographic region. The region is specified through a CoreLocation CLRegion:
        
        // let trigger = UNLocationNotificationTrigger(triggerWithRegion:region, repeats:false)
        //-----------------------------****-------------------------------
        
        ///------------------------------------------------------------------------------/////
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer), repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: .foreground)
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive, .foreground])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle])
        notificationCenter.setNotificationCategories([category])
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        if notification.request.identifier == requestIdentifier {
            
            let application = UIApplication.shared
            application.applicationIconBadgeNumber = applicationbadge + 1
            applicationbadge = applicationbadge + 1
            completionHandler( [.alert,.sound,.badge])
        }
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == requestIdentifier {
            
            let userInfo = response.notification.request.content.userInfo
            print(userInfo)
            
            print("Handling notifications with the Local Notification Identifier")
            switch response.actionIdentifier {
            case UNNotificationDismissActionIdentifier:
                print("Dismiss Action")
            case UNNotificationDefaultActionIdentifier:
                print("Default")
            case "Snooze":
                print("Snooze")
                scheduleNotification(notificationType: "Reminder", timer: 5)
            case "Delete":
                print("Delete")
            default:
                print("Unknown action")
            }
        }
        completionHandler()
    }
}
