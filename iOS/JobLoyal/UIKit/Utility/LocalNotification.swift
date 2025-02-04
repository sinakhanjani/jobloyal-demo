//
//  LocalNotification.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/20/1400 AP.
//

import NotificationCenter

class LocalNotification {
    let title, body, identifier: String
    
    init(title: String, body: String, identifier: String) {
        self.title = title
        self.body = body
        self.identifier = identifier
    }
    
    func fire(at hour: Int, and minute: Int) {
        let notificationContent = UNMutableNotificationContent()
        var dateComponent = DateComponents()

        notificationContent.title = title
        notificationContent.body = body
        notificationContent.badge = NSNumber(value: 1)
        notificationContent.sound = .default
                        
        dateComponent.hour = hour
        dateComponent.minute = minute
        dateComponent.calendar = Calendar.current
            
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    static func fire(title: String, message: String) {
        let content = UNMutableNotificationContent()
        
        content.badge = 1
        content.title = title
        content.subtitle = ""
        content.body = message
        content.categoryIdentifier = "server"
        content.sound = .default
        
        let requestIdentifier = "server.notification"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func unschedule() {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
