////
////  TotalNearView.swift
////  JobLoyal
////
////  Created by Sina khanjani on 2/27/1400 AP.
////

import UIKit

//@IBDesignable
class TotalNearView: UIView {
    override func draw(_ rect: CGRect) {
        Near.drawCanvas(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), resizing: .aspectFit)
    }
}

public class Near: NSObject {
    //// Drawing Methods
    @objc dynamic public class func drawCanvas(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 229, height: 42), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 229, height: 42), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 229, y: resizedFrame.height / 42)

        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let fillColor2 = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let fillColor3 = UIColor(red: 0.173, green: 0.455, blue: 0.961, alpha: 1.000)
        let fillColor4 = UIColor(red: 0.286, green: 0.502, blue: 0.988, alpha: 1.000)

        //// User-Screens
        //// Android-Copy-7
        //// Group 5
        //// Group- 7
        //// Rectangle
        //// path-1 Drawing
        let path1Path = UIBezierPath(roundedRect: CGRect(x: 1, y: 1, width: 227, height: 40), cornerRadius: 20)
        fillColor2.setFill()
        path1Path.fill()
        //// path- Drawing
        let pathPath = UIBezierPath(roundedRect: CGRect(x: 1, y: 1, width: 227, height: 40), cornerRadius: 20)
        fillColor3.setFill()
        pathPath.fill()
        //// Group- 10
        //// Rectangle-Copy-4 Drawing
        context.saveGState()
        context.setAlpha(0.27)
        let rectangleCopy4Path = UIBezierPath(roundedRect: CGRect(x: 10, y: 10, width: 22, height: 22), cornerRadius: 11)
        fillColor.setFill()
        rectangleCopy4Path.fill()
        context.restoreGState()
        //// Rectangle-Copy-5 Drawing
        let rectangleCopy5Path = UIBezierPath(roundedRect: CGRect(x: 14, y: 14, width: 14, height: 14), cornerRadius: 7)
        fillColor.setFill()
        rectangleCopy5Path.fill()
        //// Rectangle-Copy- Drawing
        context.saveGState()
        context.setAlpha(0.27)

        let rectangleCopyPath = UIBezierPath(roundedRect: CGRect(x: 7, y: 7, width: 28, height: 28), cornerRadius: 14)
        fillColor.setFill()
        rectangleCopyPath.fill()
        context.restoreGState()
        //// Rectangle-Copy- 2 Drawing
        let rectangleCopy2Path = UIBezierPath(roundedRect: CGRect(x: 17, y: 17, width: 8, height: 8), cornerRadius: 4)
        fillColor4.setFill()
        rectangleCopy2Path.fill()
        
        context.restoreGState()

    }

    @objc(NearResizingBehavior)
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
