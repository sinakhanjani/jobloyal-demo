//
//  JobberAboutUsViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/11/1400 AP.
//

import UIKit

class UserAboutUsViewController: UserViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = UserMenuItem.AboutUs.value
        versionLabel.text = "Version".localized() + " " + UIApplication.appVersion
    }
}
