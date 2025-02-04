//
//  NetworkViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit
//import Popup

class NetworkViewController: PresentorViewController, NetworkAPIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorReachabilityChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanges(_:)), name: .reachabilityStatusChangedNotification, object: nil)
    }
    
    @objc func reachabilityStatusChanges(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? ReachabilityStatus {
            let badConnectionVC = BadConnectionViewController.instantiateVC()
            
            switch status {
            case .offline, .unknown:
                if BadConnectionViewController.isPresented == false {
                    present(badConnectionVC)
                }
            default: break
            }
        }
    }
}

class NetworkTableViewController: UITableViewController, NetworkAPIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorReachabilityChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanges(_:)), name: .reachabilityStatusChangedNotification, object: nil)
    }
    
    @objc func reachabilityStatusChanges(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? ReachabilityStatus {
            let badConnectionVC = BadConnectionViewController.instantiateVC()
            
            switch status {
            case .offline: present(badConnectionVC, animated: true)
            case .unknown: present(badConnectionVC, animated: true)
            default: break
            }
        }
    }
}
