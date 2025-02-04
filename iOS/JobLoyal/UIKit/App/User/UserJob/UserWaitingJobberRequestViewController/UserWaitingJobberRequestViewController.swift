//
//  UserWaitingJoberRequestViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/22/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

class UserWaitingJobberRequestViewController: UserViewController, PopupConfiguration {
    
    enum Section: Hashable {
        case main
        case service
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var jobberIDLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    private var timerHelper: TimerHelper?
    
    public var item: UserAcceptJobStatusModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performTimer()
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func updateUI() {
        if let item = item {
            self.jobberIDLabel.text = item.jobber?.identifier
        }
        NotificationCenter.default.addObserver(self, selector: #selector(userStatusChanged(_:)), name: .userStatusChanged, object: nil)
    }
    
    private func performTimer() {
        let second = self.item?.remainingTime ?? JobloyalCongfiguration.Time.requestLifeTime
        
        timerHelper?.pauseTimer()
        timerHelper = nil
        timerHelper = TimerHelper(elapsedTimeInSecond: second)
        timerHelper?.start(completion: { [weak self] (second,minute) in
            self?.timerLabel.text = "Wait".localized() + " \(minute):\(second)"
            self?.timerLabel.highlight(searchedText: "Wait".localized(), color: .heavyBlue)
            // when timer is zero
            if (self?.timerHelper?.elapsedTimeInSecond ?? 0 <= 0) {
                self?.timerHelper?.pauseTimer()
                self?.timerHelper = nil
                self?.timerLabel.text = "00:00"
                self?.dismiss(animated: true)
            }
        })
    }
    
    @objc func userStatusChanged(_ notificaiton: Notification) {
        guard let item = notificaiton.userInfo?["user.item"] as? UserAcceptJobStatusModel else { return }
        self.item = item
        if let status = item.status, let userJobStatus = UserJobStatus(rawValue: status) {
            if userJobStatus == .created {
                self.performTimer()
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let alertContent = AlertContent(title: .cancel, subject: "Cancel Request".localized(), description: "Do you want to cancel this request?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.cancelOrderRequest { [weak self] in
                DispatchQueue.main.async { self?.dismiss(animated: true) }
            }
        }
        
        present(alertVC.prepare(alertVC.interactor))
    }
    
    deinit {
        jobberIdentifierHandler.remove(identifier: String(describing: self))
    }
}
