//
//  NetworkAPIDelegate.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/8/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

protocol NetworkAPIDelegate: UIViewController {
    func handleRequestByUI<S,R>(_ network: RestfulAPI<S,Generic<R>>, animated: Bool, disable buttons: [UIButton], success: @escaping (Generic<R>) -> Void, error: ((Error)->Void)?)
    func monitorReachabilityChanged()
}

extension NetworkAPIDelegate {
    public var interactor: Interactor { Interactor() }
        
    public func handleRequestByUI<S,R>(_ network: RestfulAPI<S,Generic<R>>, animated: Bool = true, disable buttons: [UIButton] = [], success: @escaping (Generic<R>) -> Void, error: ((Error)->Void)? = nil) {
        
        if animated {
            startIndicatorAnimate()
        }
        if !buttons.isEmpty {
            buttons.forEach { (button) in
                button.isUserInteractionEnabled = false
            }
        }
        
        network.sendURLSessionRequest { [weak self] (result) in
            DispatchQueue.main.async {
                if animated {
                    self?.stopIndicatorAnimate()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                if !buttons.isEmpty {
                    buttons.forEach { (button) in
                        button.isUserInteractionEnabled = true
                    }
                }
            }
            // switch server result between success and failed request
            switch result {
            case .success(let response):
                if response.success {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                        // return success result
                        success(response)
                    })
                } else {
                    if let code = response.code {
                        // token expired after one year!
                        if code == 401 {
                            let isUser = Authentication.user.isLogin ? true:false
                            isUser ? Auth.shared.user.logout():Auth.shared.jobber.logout()
                            
                            DispatchQueue.main.async {
                                let nav = UINavigationController.instantiateVC(withId: "RegisterInitializerNavigation")
                                UIApplication.shared.windows.first?.rootViewController = nav
                                UIApplication.shared.windows.first?.makeKeyAndVisible()
                            }
                            return
                        }
                        // 403 happen when user or jobber is suspend
                        if code == 403 {
                            let vc = Authentication.jobber.isLogin ? JobberSuspendViewController.instantiateVC(.jobber):UserSuspendViewController.instantiateVC(.user)
                            DispatchQueue.main.async {
                                self?.present(vc, animated: true)
                            }
                            return
                        }
                        // 115 happen when vc is open and the request is expired.
                        if code == 115 && Authentication.jobber.isLogin {
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true)
                            }
                            return
                        }
                        if code == 115 && Authentication.user.isLogin {
                            DispatchQueue.main.async {
                                self?.navigationController?.dismiss(animated: true)
                            }
                            return
                        }
                        // other open error warning view controller
                        DispatchQueue.main.async {
                            self?.handleError(code: code)
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                    // this is where the jobloyal server is down or jsonDecoder error called.
                })
            }
        }
    }
    
    func monitorReachabilityChanged() {
        let reachability = Reachability()
        reachability.monitorReachabilityChanges()
    }

    private func handleError(code: Int) {
        let alertContent: AlertContent = AlertContent(title: .none, subject: "Ops!".localized(), description: "e00".localized())

        switch code {
        case 404: alertContent.description = "e01".localized()
        case 101: alertContent.description = "e02".localized()
        case 102: alertContent.description = "e03".localized()
        case 103: alertContent.description = "e04".localized()
        case 104: alertContent.description = "e05".localized()
        case 105: alertContent.description = "e06".localized()
        case 106: alertContent.description = "e07".localized()
        case 107: alertContent.description = "e08".localized()
        case 108: alertContent.description = "e09".localized()
        case 109: alertContent.description = "e10".localized()
        case 110: alertContent.description = "e11".localized()
        case 111: alertContent.description = "e12".localized()
        case 112: alertContent.description = "e13".localized()
        case 113: alertContent.description = "e14".localized()
        case 115: alertContent.description = "e15".localized()
        case 116: alertContent.description = "e16".localized()
        case 117: alertContent.description = "e17".localized()
        case 118: alertContent.description = "e18".localized()
        case 119: alertContent.description = "e19".localized()
        case 120: alertContent.description = "e20".localized()
        case 121: alertContent.description = "e21".localized()
        case 122: alertContent.description = "e22".localized()
        case 123: alertContent.description = "e23".localized()
        case 125: alertContent.description = "e24".localized()
        case 126: alertContent.description = "e25".localized()
        default: return
        }
        
        let alertVC = WarningContentViewController
            .instantiateVC()
            .prepare(interactor)
            .alert(alertContent)
        
        present(alertVC, animated: true)
    }
}
