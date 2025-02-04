//
//  EdgeGradientView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/27/1400 AP.
//

import UIKit

//@IBDesignable
class EdgeGradientView: UIView {
    
    private let frontView = UIView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }

    override open class var layerClass: AnyClass {
        CAGradientLayer.classForCoder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientLayer = self.layer as! CAGradientLayer

        gradientLayer.colors = [#colorLiteral(red: 0.2666666667, green: 0.5137254902, blue: 0.9607843137, alpha: 1).cgColor, #colorLiteral(red: 0.2196078431, green: 0.168627451, blue: 0.9058823529, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        frontView.cornerRadius = cornerRadius - 4
        frontView.frame = CGRect(x: 0, y: 4, width: bounds.width, height: bounds.height-4)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func configUI() {
        frontView.backgroundColor = UIColor.systemGroupedBackground
        addSubview(frontView)
        sendSubviewToBack(frontView)
    }
}
