//
//  UIButtonExtension.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/2/1400 AP.
//

import UIKit

extension UIButton {
    @IBInspectable var isOn: Bool {
        get { isEnabled }
        set {
            isEnabled = newValue
            let titleColor: UIColor = isEnabled ? .white:.secondaryLabel
            let bgColor: UIColor = isEnabled ? .heavyBlue:.systemGray
            
            backgroundColor = bgColor
            setTitleColor(titleColor, for: .normal)
            setTitleColor(titleColor.withAlphaComponent(0.4), for: .highlighted)
            setTitleColor(titleColor.withAlphaComponent(0.4), for: .selected)
        }
    }
}
