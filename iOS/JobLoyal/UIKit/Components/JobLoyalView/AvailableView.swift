//
//  AvailableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit

class AvailableView: UIView {
        // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        Available.drawCanvas(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), resizing: .stretch)
    }
}



public class Available : NSObject {
    //// Drawing Methods
    @objc dynamic public class func drawCanvas(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 118, height: 40), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 118, height: 40), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 118, y: resizedFrame.height / 40)


        //// Color Declarations
        let fillColor = UIColor(red: 0.102, green: 0.357, blue: 0.820, alpha: 1.000)

        //// Jobber
        context.saveGState()
        context.setAlpha(0.04)
        context.beginTransparencyLayer(auxiliaryInfo: nil)


        //// Android-Copy-11
        //// Group 5
        //// Group-3-Copy-2
        //// Group-2-Copy
        //// where-to-go-bg Drawing
        let wheretogobgPath = UIBezierPath()
        wheretogobgPath.move(to: CGPoint(x: 0, y: 0))
        wheretogobgPath.addLine(to: CGPoint(x: 100.16, y: 0.89))
        wheretogobgPath.addCurve(to: CGPoint(x: 118, y: 18.89), controlPoint1: CGPoint(x: 110.04, y: 0.98), controlPoint2: CGPoint(x: 118, y: 9.01))
        wheretogobgPath.addLine(to: CGPoint(x: 118, y: 40))
        wheretogobgPath.addLine(to: CGPoint(x: 35.68, y: 40))
        wheretogobgPath.addLine(to: CGPoint(x: 0, y: 0))
        wheretogobgPath.close()
        wheretogobgPath.usesEvenOddFillRule = true
        fillColor.setFill()
        wheretogobgPath.fill()

        context.endTransparencyLayer()
        context.restoreGState()
        context.restoreGState()
    }

    @objc(AvailableResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
