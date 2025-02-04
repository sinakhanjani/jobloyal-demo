//
//  AppLabel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
//

import UIKit

//@IBDesignable
class AppLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
    }
    
    func setupLayer() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayer()
    }
}
