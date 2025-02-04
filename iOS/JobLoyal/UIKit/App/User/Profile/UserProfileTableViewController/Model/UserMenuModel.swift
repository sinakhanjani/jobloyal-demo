//
//  UserMenuModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit

struct UserMenuModel: Hashable {
    let menuItem: UserMenuItem
    let image: UIImage
}

enum UserMenuItem: String, Hashable {
    case ReservedServices = "Reserved Services"
    case CanceledServices = "Canceled Services"
    case ChangeInfo = "Change Info"
    case Insurance
    case TrustAndSecurity = "Trust and Security"
    case Turnover
    case TermAndConditions = "Term and Condition"
    case AboutUs = "About Us"
    case ContactUs = "Contact Us"
    case Message = "Support"
    case Logout
    
    var value: String { rawValue.localized() }
}
