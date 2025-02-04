//
//  JobberSuspendViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit
import RestfulAPI

class JobberSuspendViewController: JobberViewController {

    let jobberSuspendView = JobberSuspendView(frame: CGRect.zero, detail: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    func fetch() {
        let network = RestfulAPI<EMPTYMODEL,Generic<RCJobberSuspenedModel>>.init(path: "/jobber/suspend/detail")
            .with(auth: .jobber)
            .with(method: .GET)
        
        handleRequestByUI(network) { [weak self] (response) in
            var msg = ""
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
            
            self?.jobberSuspendView.descriptionLabel.text = msg
        }
    }
    
    private func configUI() {
        jobberSuspendView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(jobberSuspendView)
        
        NSLayoutConstraint.activate([
            // jobberSuspendView constraint:
            jobberSuspendView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            jobberSuspendView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            jobberSuspendView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            jobberSuspendView.heightAnchor.constraint(equalToConstant: 240),
        ])
    }
    
    private func updateUI() {
        fetch()
    }
}
