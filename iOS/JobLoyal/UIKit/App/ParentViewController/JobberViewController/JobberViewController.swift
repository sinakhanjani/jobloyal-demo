//
//  JobberViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit
//import Popup
import RestfulAPI

class JobberViewController: InterfaceViewController, JobberViewControllerInjection {
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(jobberPeymentStepwardDidRecievedNotification), name: .jobberJobStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidEnterForeground), name: .sceneDidEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func jobberPeymentStepwardDidRecievedNotification(_ notification: Notification) {
        guard let item = notification.userInfo?["jobber.item"] as? JobberAcceptJobStatusModel else { return }
        self.jobberOpenOrderRequestProcess(with: item)
    }
    
    @objc func sceneDidEnterForeground() {
        fetchOpenOrder()
    }
}

class JobberTableViewController: InterfaceTableViewController, JobberViewControllerInjection {
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(jobberPeymentStepwardDidRecievedNotification), name: .jobberJobStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidEnterForeground), name: .sceneDidEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func jobberPeymentStepwardDidRecievedNotification(_ notification: Notification) {
        guard let item = notification.userInfo?["jobber.item"] as? JobberAcceptJobStatusModel else { return }
        self.jobberOpenOrderRequestProcess(with: item)
    }
    
    @objc func sceneDidEnterForeground() {
        fetchOpenOrder()
    }
}

// Jobber forground notification
extension JobberViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let method = userInfo["method"] as? String ?? ""

        if method == "NEW" {
            print("---> Jobber: willPresent notification here \(userInfo) <---")
            NotificationCenter.default.post(name: .newReceiveRemoteNotification, object: nil, userInfo: userInfo)
            JobberRequestViewController.isPresenting ? completionHandler([]):completionHandler([.alert, .sound])
            return
        } else if method == "UPT" {
            print("---> Jobber: willPresent notification here \(userInfo) <---")
            fetchOpenOrder()
            completionHandler([.alert, .sound])
        } else {
            // local notification
            completionHandler([.alert, .sound, .badge])
        }
    }
}
// Jobber forground notification
extension JobberTableViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let method = userInfo["method"] as? String ?? ""

        if method == "UPT" {
            fetchOpenOrder()
        }
        print("---> JobberX: willPresent notification here \(notification.request.content.userInfo) <---")
        completionHandler([.alert, .sound])
    }
}
