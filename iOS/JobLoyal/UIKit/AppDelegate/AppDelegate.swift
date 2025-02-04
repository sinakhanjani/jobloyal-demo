//
//  AppDelegate.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/11/1399 AP.
//

import UIKit
import CoreData
import RestfulAPI
import Firebase
import Stripe

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //When your app starts, configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API.
        StripeAPI.defaultPublishableKey = JobloyalCongfiguration.StripeBank.publicKey
        // configuration RestfulAPI
        RestfulAPIConfiguration().setup { () -> APIConfiguration in
            APIConfiguration(baseURL: JobloyalCongfiguration.baseURL.value)
        }
        // configuration firebase(fcm) notification
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.applicationIconBadgeNumber = 0
        // First Launching Application
        if !UserDefaults.standard.bool(forKey: "didFinishFirstLaunchingWithOptions") {
            JobloyalCongfiguration.Notification.dailyUpdateJobStatus = true
            UserDefaults.standard.set(true, forKey: "didFinishFirstLaunchingWithOptions")
        }
//        if let option = launchOptions {
//            let info = option[UIApplication.LaunchOptionsKey.remoteNotification]
//            if info == nil {
//
//            }
//        }

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "JobLoyal")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Firebase registration notification
    func registerForRemoteNotification(application: UIApplication) {

    }

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Firebase Notification
extension AppDelegate: MessagingDelegate {
    func requestForNotificationPrivacy() {
        UNUserNotificationCenter.current().requestAuthorization(
          options: [.alert, .badge, .sound],
          completionHandler: { grand, error in
            if grand {
                UNUserNotificationCenter.current().delegate = self
            }
          }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(String(describing: fcmToken))")
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
        UIApplication.fcmToken = fcmToken
    }
        
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("XXX didReceiveRemoteNotification \(userInfo) XXX")
        
        if let method = userInfo["method"] as? String {
            if (method == "CNL") {
                NotificationCenter.default.post(name: .cnlReceiveRemoteNotification,
                                                object: nil,
                                                userInfo: userInfo)
            }
            completionHandler(.newData)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // open request tab for jobber if notification come's
        if Authentication.jobber.isLogin {
            if Authentication.jobber.isLogin {
                let info = response.notification.request.content.userInfo
                if let method = info["method"] as? String {
                    if method == "NEW" {
                        if let tbc = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController as? UITabBarController {
                            tbc.selectedIndex = 1
                        }
                    }
                }
            }
        }
        completionHandler()
    }
}
