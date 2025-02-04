//
//  JobStatus.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/2/1400 AP.
//

import Foundation

enum JobberJobStatus: String {
    case accepted
    case paid
    case arrived
    case started
    case finished
    
    var value: String {
        switch self {
        case .accepted: return "accepted".localized()
        case .paid: return "paid".localized()
        case .arrived: return "arrived".localized()
        case .started: return "started".localized()
        case .finished: return "finished".localized()
        }
    }
    
    func currentVCIdentifier(isNumeric: Bool) -> String {
        switch self {
        case .accepted: return isNumeric ? JobberWaitingRequestViewController.identifier:JobberOrderBeginRequestViewController.identifier
        case .paid: return JobberOrderBeginRequestViewController.identifier
        case .arrived: return JobberOrderInRequestArrivedViewController.identifier
        case .started: return JobberOrderInRequestStartedViewController.identifier
        case .finished: return JobberWaitingOrderPaymentViewController.identifier
        }
    }
}
