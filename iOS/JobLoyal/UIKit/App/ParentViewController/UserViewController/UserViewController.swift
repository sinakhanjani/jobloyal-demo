//
//  UserViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit
//import Popup
import RestfulAPI

class UserViewController: InterfaceViewController, UserViewControllerInjection {
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(userPeymentStepwardDidRecievedNotification), name: .userJobStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidEnterForeground), name: .sceneDidEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func userPeymentStepwardDidRecievedNotification(_ notification: Notification) {
        guard let item = notification.userInfo?["user.item"] as? UserAcceptJobStatusModel else { return }
        userOpenOrderRequestProcess(with: item)
    }
    
    @objc func sceneDidEnterForeground() {
        fetchOpenOrder()
    }
}

class UserTableViewController: InterfaceTableViewController, UserViewControllerInjection {
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(userPeymentStepwardDidRecievedNotification), name: .userJobStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidEnterForeground), name: .sceneDidEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func userPeymentStepwardDidRecievedNotification(_ notification: Notification) {
        guard let item = notification.userInfo?["user.item"] as? UserAcceptJobStatusModel else { return }
        userOpenOrderRequestProcess(with: item)
    }
    
    @objc func sceneDidEnterForeground() {
        fetchOpenOrder()
    }
}

// User forgorund notification
extension UserViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let method = userInfo["method"] as? String ?? ""
        
        if method == "CNL" {
            print("---> User: willPresent notification here \(notification.request.content.userInfo) <---")
            fetchOpenOrder()
            completionHandler([.alert, .sound])
            return
        }

        if method == "UPT" {
            print("---> User: willPresent notification here \(notification.request.content.userInfo) <---")
            fetchOpenOrder()
            completionHandler([])
        }
    }
}
// User forgorund notification
extension UserTableViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let method = userInfo["method"] as? String ?? ""
        
        if method == "CNL" {
            print("---> UserX: willPresent notification here \(notification.request.content.userInfo) <---")
            fetchOpenOrder()
            completionHandler([.alert, .sound])
            return
        }

        if method == "UPT" {
            print("---> UserX: willPresent notification here \(notification.request.content.userInfo) <---")
            fetchOpenOrder()
            completionHandler([])
        }

        print("---> User: willPresent notification here \(notification.request.content.userInfo) <---")
    }
}
