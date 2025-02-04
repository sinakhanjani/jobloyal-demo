//
//  UserViewControllerInjection.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/9/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

private let slideDownTransitionAnimator = SlideDownTransitionAnimator()
var userIdentifierHandler = IdentifierHandler(authentication: .user)

protocol UserViewControllerInjection: NetworkAPIDelegate {
    func userOpenOrderRequestProcess(with model: UserAcceptJobStatusModel)
    func userOpenOrderRequest(completion: @escaping (UserAcceptJobStatusModel?) -> Void)
    func cancelOrderRequest(completion: @escaping () -> Void)
    func fetchOpenOrder()
}

extension UserViewControllerInjection {
    public var interactor: Interactor { Interactor() }

    internal func setupUserStatus(item: UserAcceptJobStatusModel, currentVCDescription: String) {
        let currentVCIndentifier = type(of: presentedViewController ?? self).identifier
        print("XXX XXX XXX", currentVCIndentifier, "XXX XXX XXX")
        guard !userIdentifierHandler.isContain(currentVCDescription: currentVCDescription) else {
            NotificationCenter.default.post(name: .userStatusChanged, object: nil, userInfo: ["user.item":item])

            return
        }
        // access to root view controller
        let rootViewController = UIApplication.shared.rootViewController
        // check witch view controller is current identifier
        switch currentVCDescription {
        case UserWaitingJobberRequestViewController.identifier:
            let vc = UserWaitingJobberRequestViewController
                .instantiateVC(.user)
            // insert item to vc
            vc.transitioningDelegate = slideDownTransitionAnimator
            vc.item = item
            // present from root view controller
            rootViewController?.present(vc, animated: true)
        case UserJobberAcceptanceOpenAppViewController.identifier:
            let nc = UINavigationController.instantiateVC(.user, withId: "UserJobberAcceptanceOpenAppNavigationViewController") as! UINavigationController
            if let vc = nc.viewControllers.first as? UserJobberAcceptanceOpenAppViewController {
                vc.item = item
            }

            if currentVCIndentifier == UserWaitingJobberRequestViewController.identifier {
                self.dismiss(animated: true) {
                    rootViewController!.present(nc, animated: true)
                }
            } else { rootViewController?.present(nc, animated: true) }
        case UserRatingTableViewController.identifier:
            let nc = UINavigationController.instantiateVC(.user, withId: "UserRatingTableViewControllerNavigationViewController") as! UINavigationController
            if let vc = nc.viewControllers.first as? UserRatingTableViewController {
                // insert item to vc
                vc.item = item.jobber
            }
            
            if (currentVCIndentifier == UserJobberAcceptanceJobTableViewController.identifier) || (currentVCIndentifier == UserJobberJobHourFactorTableViewController.identifier) {
                self.navigationController?.dismiss(animated: true) {
                    rootViewController?.present(nc, animated: true)
                }
            } else { rootViewController?.present(nc, animated: true) }
        default: break
        }
        // add currentVCDescription identifier to handler controller
        userIdentifierHandler.append(identifier: currentVCDescription)
    }

    internal func userOpenOrderRequestProcess(with model: UserAcceptJobStatusModel) {
        guard let status = model.status else { return }
        guard let userJobStatus = UserJobStatus(rawValue: status) else { return }
        setupUserStatus(item: model, currentVCDescription: userJobStatus.currentVCIdentifier)
    }
    
    internal func userOpenOrderRequest(completion: @escaping (_ model: UserAcceptJobStatusModel?) -> Void) {
        let network = RestfulAPI<EMPTYMODEL,Generic<UserAcceptJobStatusModel>>.init(path: "/user/request/status_last_request")
            .with(auth: .user)

        handleRequestByUI(network, animated: false) { (response) in
            completion(response.data)
        }
    }
    
    public func fetchOpenOrder() {
        userOpenOrderRequest { [weak self] (item) in
            guard let self = self else { return }
            guard let item = item else {
                let currentVC = self.presentedViewController ?? self
                let identifier = type(of: currentVC).identifier
                if currentVC.restorationIdentifier == "openOrderController" || identifier == UserJobberAcceptanceJobTableViewController.identifier {
                    currentVC.dismiss(animated: true)
                }
                
                userIdentifierHandler.reset()
                return
            }
            // send data with local notification
            NotificationCenter.default.post(name: .userJobStatus, object: nil, userInfo: ["user.item":item])
        }
    }
    
    public func fetchOpenOrderEvery(_ second: Double) {
        Timer.scheduledTimer(withTimeInterval: second, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.fetchOpenOrder()
        })
    }
    
    public func userOpenOrderNotificationProcess(with model: UserAcceptJobStatusModel?) {
        guard let model = model else {
            if let presentedVC = self.presentedViewController,
               presentedVC.restorationIdentifier == "openOrderController" {
                presentedVC.dismiss(animated: true)
            }
            userIdentifierHandler.reset()

            return
        }
        
        NotificationCenter.default.post(name: .userJobStatus, object: nil, userInfo: ["user.item":model])
    }
    
    func cancelOrderRequest(completion: @escaping () -> Void) {
        let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/user/request/cancel")
            .with(auth: .user)
            .with(method: .POST)
        
        handleRequestByUI(network) { (response) in
            completion()
        }
    }
}
