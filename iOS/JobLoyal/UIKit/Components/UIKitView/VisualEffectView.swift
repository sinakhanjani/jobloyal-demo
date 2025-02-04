//
//  VisualEffectView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
// https://github.com/efremidze/VisualEffectView

import UIKit

extension UIView {
    @discardableResult
    func constrain(constraints: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        let constraints = constraints(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func constrainToEdges(_ inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return constrain {[
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: inset.top),
            $0.leadingAnchor.constraint(equalTo: $0.superview!.leadingAnchor, constant: inset.left),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: inset.bottom),
            $0.trailingAnchor.constraint(equalTo: $0.superview!.trailingAnchor, constant: inset.right)
            ]}
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    class var red: UIColor { return UIColor(red: 255, green: 59, blue: 48) }
    class var orange: UIColor { return UIColor(red: 255, green: 149, blue: 0) }
    class var yellow: UIColor { return UIColor(red: 255, green: 204, blue: 0) }
    class var green: UIColor { return UIColor(red: 76, green: 217, blue: 100) }
    class var tealBlue: UIColor { return UIColor(red: 90, green: 200, blue: 250) }
    class var blue: UIColor { return UIColor(red: 0, green: 122, blue: 255) }
    class var purple: UIColor { return UIColor(red: 88, green: 86, blue: 214) }
    class var pink: UIColor { return UIColor(red: 255, green: 45, blue: 85) }
    class var allCases: [UIColor] {
        return [red, orange, yellow, green, tealBlue, blue, purple, pink]
    }
}

extension VisualEffectView {
    func tint(_ color: UIColor, blurRadius: CGFloat) {
        self.colorTint = color
        self.colorTintAlpha = 0.5
        self.blurRadius = blurRadius
    }
}

/// VisualEffectView is a dynamic background blur view.
open class VisualEffectView: UIVisualEffectView {
    
    /// Returns the instance of UIBlurEffect.
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    /**
     Tint color.
     
     The default value is nil.
     */
    open var colorTint: UIColor? {
        get {
            if #available(iOS 14, *) {
                return ios14_colorTint
            } else {
                return _value(forKey: .colorTint)
            }
        }
        set {
            if #available(iOS 14, *) {
                ios14_colorTint = newValue
            } else {
                _setValue(newValue, forKey: .colorTint)
            }
        }
    }
    
    /**
     Tint color alpha.
     Don't use it unless `colorTint` is not nil.
     The default value is 0.0.
     */
    open var colorTintAlpha: CGFloat {
        get { return _value(forKey: .colorTintAlpha) ?? 0.0 }
        set {
            if #available(iOS 14, *) {
                ios14_colorTint = ios14_colorTint?.withAlphaComponent(newValue)
            } else {
                _setValue(newValue, forKey: .colorTintAlpha)
            }
        }
    }
    
    /**
     Blur radius.
     The default value is 0.0.
     */
    open var blurRadius: CGFloat {
        get {
            if #available(iOS 14, *) {
                return ios14_blurRadius
            } else {
                return _value(forKey: .blurRadius) ?? 0.0
            }
        }
        set {
            if #available(iOS 14, *) {
                ios14_blurRadius = newValue
            } else {
                _setValue(newValue, forKey: .blurRadius)
            }
        }
    }
    
    /**
     Scale factor.
     
     The scale factor determines how content in the view is mapped from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
     
     The default value is 1.0.
     */
    open var scale: CGFloat {
        get { return _value(forKey: .scale) ?? 1.0 }
        set { _setValue(newValue, forKey: .scale) }
    }
    
    // MARK: - Initialization
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
        scale = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scale = 1
    }
    
}

// MARK: - Helpers
private extension VisualEffectView {
    
    /// Returns the value for the key on the blurEffect.
    func _value<T>(forKey key: Key) -> T? {
        return blurEffect.value(forKeyPath: key.rawValue) as? T
    }
    
    /// Sets the value for the key on the blurEffect.
    func _setValue<T>(_ value: T?, forKey key: Key) {
        blurEffect.setValue(value, forKeyPath: key.rawValue)
        if #available(iOS 14, *) {} else {
            self.effect = blurEffect
        }
    }
    
    enum Key: String {
        case colorTint, colorTintAlpha, blurRadius, scale
    }
    
}

// ["grayscaleTintLevel", "grayscaleTintAlpha", "lightenGrayscaleWithSourceOver", "colorTint", "colorTintAlpha", "colorBurnTintLevel", "colorBurnTintAlpha", "darkeningTintAlpha", "darkeningTintHue", "darkeningTintSaturation", "darkenWithSourceOver", "blurRadius", "saturationDeltaFactor", "scale", "zoom"]

@available(iOS 14, *)
extension UIVisualEffectView {
    var ios14_blurRadius: CGFloat {
        get {
            return gaussianBlur?.requestedValues?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            prepareForChanges()
            gaussianBlur?.requestedValues?["inputRadius"] = newValue
            applyChanges()
        }
    }
    var ios14_colorTint: UIColor? {
        get {
            return sourceOver?.value(forKeyPath: "color") as? UIColor
        }
        set {
            prepareForChanges()
            sourceOver?.setValue(newValue, forKeyPath: "color")
            sourceOver?.perform(Selector(("applyRequestedEffectToView:")), with: overlayView)
            applyChanges()
        }
    }
}

private extension UIVisualEffectView {
    var backdropView: UIView? {
        return subview(of: NSClassFromString("_UIVisualEffectBackdropView"))
    }
    var overlayView: UIView? {
        return subview(of: NSClassFromString("_UIVisualEffectSubview"))
    }
    var gaussianBlur: NSObject? {
        return backdropView?.value(forKey: "filters", withFilterType: "gaussianBlur")
    }
    var sourceOver: NSObject? {
        return overlayView?.value(forKey: "viewEffects", withFilterType: "sourceOver")
    }
    func prepareForChanges() {
        self.effect = UIBlurEffect(style: .light)
        gaussianBlur?.setValue(1.0, forKeyPath: "requestedScaleHint")
    }
    func applyChanges() {
        backdropView?.perform(Selector(("applyRequestedFilterEffects")))
    }
}

private extension NSObject {
    var requestedValues: [String: Any]? {
        get { return value(forKeyPath: "requestedValues") as? [String: Any] }
        set { setValue(newValue, forKeyPath: "requestedValues") }
    }
    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        return (value(forKeyPath: key) as? [NSObject])?.first { $0.value(forKeyPath: "filterType") as? String == filterType }
    }
}

private extension UIView {
    func subview(of classType: AnyClass?) -> UIView? {
        return subviews.first { type(of: $0) == classType }
    }
}
