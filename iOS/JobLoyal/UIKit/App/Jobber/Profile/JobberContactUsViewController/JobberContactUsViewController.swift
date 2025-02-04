//
//  ContactUsViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/11/1400 AP.
//

import UIKit

class JobberContactUsViewController: JobberViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = JobberMenuItem.ContactUs.value
    }
}
