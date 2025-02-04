//
//  UserSuspendViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/22/1400 AP.
//

import UIKit
import RestfulAPI

class UserSuspendViewController: UserViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        fetch()
    }
    
    private func fetch() {
        let network = RestfulAPI<EMPTYMODEL,Generic<RCJobberSuspenedModel>>.init(path: "/user/suspend/detail")
            .with(auth: .user)
        
        handleRequestByUI(network) { [weak self] (response) in
            var msg = ""
            //
            if let data = response.data {
                msg = data.reason ?? "Your account is suspend !".localized()
            } else { msg = "Your account is suspend !".localized() }
            
            if let createAt = response.data?.createdAt?.to(date: "YYYY-MM-dd HH:mm") {
                msg += "\n" + "Suspend date is".localized() + " \(createAt)"
            }
            
            if let expiredDate = response.data?.expired?.to(date: "YYYY-MM-dd HH:mm"), let finite = response.data?.finite {
                if finite {
                    msg += "\n" + "Expired date is".localized() + " \(expiredDate)"
                }
            } else { msg += "\n" + "Expired date is never".localized() }
            
            self?.descriptionLabel.text = msg
        }
    }
}
