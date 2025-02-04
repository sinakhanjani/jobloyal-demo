//
//  BaseViewControllerInjection.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/9/1400 AP.
//

import UIKit
import CoreLocation
//import Popup

protocol BaseViewControllerInjection: UIViewController {
    
}

extension BaseViewControllerInjection {
    public func checkAccessGPS(locationManager: CLLocationManager) -> Bool {
        func locationAlert() {
            // Check for Location Services
            let alertContent = AlertContent(title: .none, subject: "LocationAccessDenied".localized(), description: "LocationDeniedBody".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)

            present(warningVC.prepare(warningVC.interactor),animated: true)
        }
        
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch locationManager.authorizationStatus {
                case .restricted, .denied:
                    locationAlert()
                    return false
                default: return true
                }
            } else {
                // Fallback on earlier versions
            }
        } else { locationAlert() }
        
        return false
    }
}
