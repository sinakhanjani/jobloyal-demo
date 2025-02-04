//
//  InsetTextField.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
//

import UIKit

//@IBDesignable
class InsetTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 6 {
       didSet { layoutIfNeeded() }
    }
    
    @IBInspectable var insetY: CGFloat = 6 {
       didSet { layoutIfNeeded() }
    }

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
}
