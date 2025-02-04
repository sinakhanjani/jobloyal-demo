//
//  WhoAreYouViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import UIKit

class WhoAreYouViewController: InterfaceViewController {
    
    private let toUserIdentitySegue = "toUserIdentitySegue"
    private let toJobberIdentitySegue = "toJobberIdentitySegue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhoneNumberViewController
        
        vc.auth = (segue.identifier == toUserIdentitySegue) ? .user:.jobber
    }
}
