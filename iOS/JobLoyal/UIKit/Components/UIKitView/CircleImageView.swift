//
//  CircleImageView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
//

import UIKit

//@IBDesignable
class CircleImageView: UIImageView {
    @IBInspectable var circular: Bool = false {
        didSet { applyCornerRadius() }
    }
    
    func applyCornerRadius() {
        if (circular) {
            layer.cornerRadius = bounds.size.height / 2
            layer.masksToBounds = true
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = CGFloat(borderWidth)
        } else {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = CGFloat(borderWidth)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius()
    }
}
