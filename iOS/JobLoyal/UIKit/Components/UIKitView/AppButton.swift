//
//  AppButton.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
//

import UIKit

//@IBDesignable
class AppButton: UIButton {
    func setupLayer() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayer()
    }
}
