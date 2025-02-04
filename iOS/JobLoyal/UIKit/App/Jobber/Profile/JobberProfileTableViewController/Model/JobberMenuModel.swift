//
//  MenuModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit

struct JobberMenuModel: Hashable {
    let menuItem: JobberMenuItem
    let image: UIImage
}

enum JobberMenuItem: String, Hashable {
    case Payment = "Payment Method"
    case Notification
    case EditProfile = "Edit Profile"
    case Turnover
    case Message = "Support"
    case Insurance
    case TermAndConditions = "Term and Condition"
    case AboutUs = "About Us"
    case ContactUs = "Contact Us"
    case Logout
    
    var value: String { rawValue.localized() }
}
