//
//  ContactUsViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/11/1400 AP.
//

import UIKit

class UserContactUsViewController: UserViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = UserMenuItem.ContactUs.value
    }
}
