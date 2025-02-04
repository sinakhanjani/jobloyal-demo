//
//  JobberViewControllerInjection.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/9/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

private let slideDownTransitionAnimator = SlideDownTransitionAnimator()
var jobberIdentifierHandler = IdentifierHandler(authentication: .jobber)

protocol JobberViewControllerInjection: NetworkAPIDelegate {
    func jobberOpenOrderRequestProcess(with model: JobberAcceptJobStatusModel)
    func jobberOpenOrderRequest(completion: @escaping (JobberAcceptJobStatusModel?) -> Void)
    func cancelOrderRequest(completion: @escaping () -> Void)
    func fetchOpenOrder()
}

extension JobberViewControllerInjection {
    public var interactor: Interactor { Interactor() }

    internal func setupJoberStatus(item: JobberAcceptJobStatusModel, currentVCDescription: String) {
        let currentVCIndentifier = type(of: presentedViewController ?? self).identifier
        print("XXX XXX XXX", currentVCIndentifier, "XXX XXX XXX")
        // condition if this viwwController as a will present viewController
        guard !jobberIdentifierHandler.isContain(currentVCDescription: currentVCDescription) else {
            NotificationCenter.default.post(name: .jobberStatusChanged, object: nil, userInfo: ["jobber.item":item])
            return
        }
        // access to root view controller
        let rootViewController = UIApplication.shared.rootViewController
        // guard condition true then:
        switch currentVCDescription {
        case JobberWaitingRequestViewController.identifier:
            let vc = JobberWaitingRequestViewController
                .instantiateVC(.jobber)
            vc.transitioningDelegate = slideDownTransitionAnimator
            vc.item = item
            
            rootViewController?.present(vc, animated: true)
        case JobberOrderBeginRequestViewController.identifier:
            let vc = JobberOrderBeginRequestViewController
                .instantiateVC(.jobber)
                .prepare(self.interactor)
            vc.item = item

            if currentVCIndentifier == JobberWaitingRequestViewController.identifier {
                self.dismiss(animated: true) { rootViewController?.present(vc, animated: true) }
            } else { rootViewController?.present(vc, animated: true) }
        case JobberOrderInRequestArrivedViewController.identifier:
            let vc = JobberOrderInRequestArrivedViewController
                .instantiateVC(.jobber)
                .prepare(self.interactor)
            vc.item = item
            
            if currentVCIndentifier == JobberOrderBeginRequestViewController.identifier {
                self.dismiss(animated: true) {
                    rootViewController?.present(vc, animated: true)
                }
            } else { rootViewController?.present(vc, animated: true) }
        case JobberOrderInRequestStartedViewController.identifier:
            let vc = JobberOrderInRequestStartedViewController
                .instantiateVC(.jobber)
                .prepare(self.interactor)
            vc.item = item
            
            if currentVCIndentifier == JobberOrderInRequestArrivedViewController.identifier {
                self.dismiss(animated: true) { rootViewController?.present(vc, animated: true) }
            } else { rootViewController?.present(vc, animated: true) }
        case JobberWaitingOrderPaymentViewController.identifier:
            let vc = JobberWaitingOrderPaymentViewController
                .instantiateVC(.jobber)
                .prepare(self.interactor)
            vc.item = item

            if currentVCIndentifier == JobberOrderInRequestStartedViewController.identifier {
                self.dismiss(animated: true) { rootViewController?.present(vc, animated: true) }
            } else { rootViewController?.present(vc, animated: true) }
        default: break
        }
        // add currentVCDescription identifier to handler controller
        jobberIdentifierHandler.append(identifier: currentVCDescription)
    }
    
    internal func jobberOpenOrderRequestProcess(with model: JobberAcceptJobStatusModel) {
        // process status for jobber (do everything here)
        // warning: don't forget mainQueue thread in all steps
        guard let status = model.status else { return }
        guard let jobStatus = JobberJobStatus(rawValue: status) else { return }
        JobloyalCongfiguration.Time.userTimePaying = model.userTimePaying
        // check is numeric or hour type
        let isNumeric = !model.timeBase
        let mustDisplayVCIdentifier = jobStatus.currentVCIdentifier(isNumeric: isNumeric)
        setupJoberStatus(item: model, currentVCDescription: mustDisplayVCIdentifier)
    }

    internal func jobberOpenOrderRequest(completion: @escaping (_ model: JobberAcceptJobStatusModel?) -> Void) {
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberAcceptJobStatusModel>>.init(path: "/jobber/request/status_last_request")
            .with(auth: .jobber)
            
        handleRequestByUI(network, animated: false) { (response) in
            completion(response.data)
        }
    }
    
    func fetchOpenOrder() {
        jobberOpenOrderRequest { [weak self] (item) in
            guard let self = self else { return }
            guard let item = item else {
                let currentVC = self.presentedViewController ?? self
                if currentVC.restorationIdentifier == "openOrderController" {
                    currentVC.dismiss(animated: true)
                }
                
                jobberIdentifierHandler.reset()
                return
            }
            
            NotificationCenter.default.post(name: .jobberJobStatus, object: nil, userInfo: ["jobber.item":item])
        }
    }
    
    public func fetchOpenOrderEvery(_ second: Double) {
        Timer.scheduledTimer(withTimeInterval: second, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.fetchOpenOrder()
        })
    }
    
    public func jobberOpenOrderNotificationProcess(with model: JobberAcceptJobStatusModel?) {
        guard let model = model else {
            let currentVC = presentedViewController ?? self
            if currentVC.restorationIdentifier == "openOrderController" {
                currentVC.dismiss(animated: true)
            }

            jobberIdentifierHandler.reset()
            return
        }
        
        NotificationCenter.default.post(name: .jobberJobStatus, object: nil, userInfo: ["jobber.item":model])
    }
    
    func cancelOrderRequest(completion: @escaping () -> Void) {
        let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/jobber/request/cancel")
            .with(auth: .jobber)
            .with(method: .POST)
            
        handleRequestByUI(network) { (response) in
            completion()
        }
    }
}
