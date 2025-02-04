//
//  DismissAnimator.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit

public class DismissAnimator: NSObject { }

extension DismissAnimator: UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = UITransitionContextViewControllerKey.from
        guard let from = transitionContext.viewController(forKey: key) else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                from.view.frame = finalFrame
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
