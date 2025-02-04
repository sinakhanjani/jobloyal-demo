//
//  PopupViewController.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit

open class PresentorViewController: UIViewController, PopupCoordinator {
    
    public var interactor: Interactor = Interactor()
    public var animated: Bool = true

    public func present(_ vc: UIViewController) {
        vc.transitioningDelegate = self
        present(vc, animated: animated)
    }
}

extension PresentorViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
