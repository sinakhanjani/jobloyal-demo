//
//  CardView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/27/1400 AP.
//

import UIKit

//@IBDesignable
class ServiceCardView: UIView {
    @IBInspectable var strokeColor: UIColor = .clear {
        didSet { layoutIfNeeded() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLine()
    }
    
    override func draw(_ rect: CGRect) {
        ServiceCard.drawCanvas(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), resizing: .stretch, strokeColor: strokeColor)
    }
    
    func setupLine() {
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.lineWidth = 0.4
        lineLayer.lineDashPattern = [4,4]
        let path = CGMutablePath()
        let x: CGFloat = (frame.width/8)*5.41
        let y: CGFloat = 20
        path.addLines(between: [CGPoint(x: x, y: y),
                                CGPoint(x: x, y: frame.height - y)])
        lineLayer.path = path
        layer.addSublayer(lineLayer)
    }
}

public class ServiceCard: NSObject {
    //// Drawing Methods
    @objc dynamic public class func drawCanvas(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 338, height: 98), resizing: ResizingBehavior = .aspectFit, strokeColor: UIColor = #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 338, height: 98), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 338, y: resizedFrame.height / 98)

        //// Color Declarations
        let fillColor = UIColor.clear

        //// User-Screens
        //// Android-Copy-23
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: 7, y: 1))
        rectanglePath.addLine(to: CGPoint(x: 214.5, y: 1))
        rectanglePath.addCurve(to: CGPoint(x: 228.58, y: 10.69), controlPoint1: CGPoint(x: 219.23, y: 7.46), controlPoint2: CGPoint(x: 223.92, y: 10.69))
        rectanglePath.addCurve(to: CGPoint(x: 242.55, y: 1), controlPoint1: CGPoint(x: 233.24, y: 10.69), controlPoint2: CGPoint(x: 237.9, y: 7.46))
        rectanglePath.addLine(to: CGPoint(x: 331, y: 1))
        rectanglePath.addCurve(to: CGPoint(x: 337, y: 7), controlPoint1: CGPoint(x: 334.31, y: 1), controlPoint2: CGPoint(x: 337, y: 3.69))
        rectanglePath.addLine(to: CGPoint(x: 337, y: 91))
        rectanglePath.addCurve(to: CGPoint(x: 331, y: 97), controlPoint1: CGPoint(x: 337, y: 94.31), controlPoint2: CGPoint(x: 334.31, y: 97))
        rectanglePath.addLine(to: CGPoint(x: 242.55, y: 97))
        rectanglePath.addCurve(to: CGPoint(x: 228.5, y: 89.5), controlPoint1: CGPoint(x: 237.86, y: 92), controlPoint2: CGPoint(x: 233.18, y: 89.5))
        rectanglePath.addCurve(to: CGPoint(x: 214.5, y: 97), controlPoint1: CGPoint(x: 223.82, y: 89.5), controlPoint2: CGPoint(x: 219.16, y: 92))
        rectanglePath.addLine(to: CGPoint(x: 7, y: 97))
        rectanglePath.addCurve(to: CGPoint(x: 1, y: 91), controlPoint1: CGPoint(x: 3.69, y: 97), controlPoint2: CGPoint(x: 1, y: 94.31))
        rectanglePath.addLine(to: CGPoint(x: 1, y: 7))
        rectanglePath.addCurve(to: CGPoint(x: 7, y: 1), controlPoint1: CGPoint(x: 1, y: 3.69), controlPoint2: CGPoint(x: 3.69, y: 1))
        rectanglePath.close()
        rectanglePath.usesEvenOddFillRule = true
        fillColor.setFill()
        rectanglePath.fill()
        strokeColor.setStroke()
        rectanglePath.lineWidth = 1
        rectanglePath.miterLimit = 4
        rectanglePath.stroke()
        
        context.restoreGState()

    }

    @objc(CardResizingBehavior)
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
