//
//  Jender.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

enum Gender {
    case men, women, none
    
    var value: String {
        switch self {
        case .men: return "Men".localized()
        case .women: return "Women".localized()
        case .none: return "None".localized()
        }
    }
    
    var isMen: String {
        switch self {
        case .men: return "true"
        case .women: return "false"
        case .none: return "false"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .men:
            return UIImage(systemName: "gender")
        case .women:
            return UIImage(systemName: "gender")
        case .none:
            return UIImage(systemName: "none")
        }
    }
}
