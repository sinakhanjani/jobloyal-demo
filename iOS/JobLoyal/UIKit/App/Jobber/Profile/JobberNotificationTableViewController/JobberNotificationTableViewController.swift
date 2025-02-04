//
//  JobberNotificationTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit
import RestfulAPI

class JobberNotificationTableViewController: JobberTableViewController {

    @IBOutlet weak var notificationSwitchButton: UISwitch!
    @IBOutlet weak var dailyJobActivationReminderSwitchButton: UISwitch!
    
    public var statics: Statics?
    private let localNotification = JobloyalCongfiguration.Notification.self
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if statics == nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(jobberProfileChanged(_:)), name: .jobberProfileChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Notification".localized()
        notificationSwitchButton.isOn = (statics?.notificationEnabled ?? false)
        dailyJobActivationReminderSwitchButton.isOn = localNotification.dailyUpdateJobStatus
    }
    
    private func setNotificationRequest() {
        struct SendNotificationModel: Codable { let sms: Bool ; let notification: Bool }
        let network = RestfulAPI<SendNotificationModel,Generic<EMPTYMODEL>>.init(path: "/jobber/profile/edit_notification")
            .with(body: SendNotificationModel(sms: false, notification: notificationSwitchButton.isOn))
            .with(auth: .jobber)
            .with(method: .POST)
        
        handleRequestByUI(network) { _ in
            //
        }
    }
    
    @objc func jobberProfileChanged(_ notification: Notification) {
        guard let item = notification.userInfo?["jobber.profile"] as? JobberProfileModel else { return }
        self.statics = item.statics
        updateUI()
    }
    
    @objc private func fetchMatchingItems() {
        setNotificationRequest()
    }
    
    @IBAction func switchsButtonValueChanged(_ sender: UISwitch) {
        // perform request.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 1)
    }
    
    @IBAction func dailyJobActivationReminderValueChanged(_ sender: UISwitch) {
        JobloyalCongfiguration
            .Notification
            .dailyUpdateJobStatus = sender.isOn
        sender.isOn ?
            localNotification.dailyUpdateJob
            .fire(at: 7, and: 0)
            :
            localNotification.dailyUpdateJob
            .unschedule()
    }
}
