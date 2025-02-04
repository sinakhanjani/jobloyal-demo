//
//  UnitType.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import Foundation

enum UnitTypeModel {
    case numeric, hour, none
    
    var value: String {
        switch self {
        case .numeric: return "Numeric".localized()
        case .hour: return "Hour".localized()
        case .none: return "None".localized()
        }
    }
}
