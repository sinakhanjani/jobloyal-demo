//
//  HintInjection.swift
//  Nerkh
//
//  Created by Sina khanjani on 1/25/1399 AP.
//  Copyright © 1399 Sina Khanjani. All rights reserved.
//

import UIKit

protocol CircleHintInjection {
    func showHelperCircle(to view: UIView)
}

extension CircleHintInjection {
    func showHelperCircle(to view: UIView) {
        let center = CGPoint(x: (view.bounds.width*0.5)-15, y: 128)
        let small = CGSize(width: 30, height: 30)
        let circle = UIView(frame: CGRect(origin: center, size: small))
        circle.layer.cornerRadius = circle.frame.width/2
        circle.backgroundColor = UIColor.white
        circle.layer.shadowOpacity = 0.8
        circle.layer.shadowOffset = CGSize()
        view.addSubview(circle)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [],
            animations: {
                circle.frame.origin.y += 200
                circle.layer.opacity = 0
            },
            completion: { _ in
                circle.removeFromSuperview()
            }
        )
    }
}
