//
//  WaitingViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit
//import Popup

class JobberWaitingRequestViewController: JobberViewController, PopupConfiguration {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: AppButton!
    
    private var timerHelper: TimerHelper?
    
    public var item: JobberAcceptJobStatusModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    private func updateUI() {
        if let item = item {
            titleLabel.text = "Wait for pay".localized() + " " + item.total + " CHF"
            titleLabel.highlight(searchedText: "Wait".localized(), color: .heavyBlue)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(jobberStatusChanged(_:)), name: .jobberStatusChanged, object: nil)
    }
    
    private func performTimer() {
        guard let remainingTime = item?.remainingTimeToPay else { return }
        
        timerHelper?.pauseTimer()
        timerHelper = nil
        timerHelper = TimerHelper(elapsedTimeInSecond: remainingTime)
        timerHelper?.start(completion: { [weak self] (second,minute) in
            self?.cancelButton.setTitle("Cancel".localized() + " \(minute):\(second)", for: .normal)
            // when timer is zero:
            if (self?.timerHelper?.elapsedTimeInSecond ?? 0) <= 0 {
                self?.timerHelper?.pauseTimer()
                self?.timerHelper = nil
                self?.cancelButton.isOn = true
                self?.cancelButton.setTitle("Cancel Request".localized(), for: [.normal])
            }
        })
    }
    
    @objc func jobberStatusChanged(_ notificaiton: Notification) {
        guard let item = notificaiton.userInfo?["jobber.item"] as? JobberAcceptJobStatusModel else { return }
        
        self.item = item
        
        if let status = item.status, let jobberJobStatus = JobberJobStatus(rawValue: status) {
            if jobberJobStatus == .accepted {
                self.performTimer()
            }
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        let alertContent = AlertContent(title: .cancel, subject: "Cancel Request".localized(), description: "Do you want to cancel this order?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            // send cancel request and then call this:
            self?.cancelOrderRequest { [weak self] in
                self?.timerHelper?.pauseTimer()
                self?.timerHelper = nil
                DispatchQueue.main.async { self?.dismiss(animated: true) }
            }
        }
        
        present(alertVC.prepare(alertVC.interactor))
    }
    
    deinit {
        jobberIdentifierHandler.remove(identifier: String(describing: self))
    }
}
