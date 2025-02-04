//
//  UserJobStatus.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/2/1400 AP.
//

import Foundation

enum UserJobStatus: String {
    case created
    case accepted
    case paid
    case arrived
    case started
    case finished
    case verified

    var value: String {
        switch self {
        case .created: return "created".localized()
        case .accepted: return "accepted".localized()
        case .paid: return "paid".localized()
        case .arrived: return "arrived".localized()
        case .started: return "started".localized()
        case .finished: return "finished".localized()
        case .verified: return "verified".localized()
        }
    }
    
    var currentVCIdentifier: String {
        switch self {
        case .created: return UserWaitingJobberRequestViewController.identifier
        case .verified: return UserRatingTableViewController.identifier
        default: return UserJobberAcceptanceOpenAppViewController.identifier
        }
    }
}
