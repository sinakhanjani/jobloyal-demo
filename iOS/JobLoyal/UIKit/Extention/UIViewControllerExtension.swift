//
//  UIViewExtension.swift
//  Master
//
//  Created by Sina khanjani on 10/9/1399 AP.
//
import UIKit

extension UIViewController {
    /// Instantiate ViewController by identifier on storyboard
    public static func instantiateVC(_ storyboard: Storyboard = .main) -> Self {
        func create<T : UIViewController> (type: T.Type) -> T {
            let uiStoryboard = UIStoryboard(name: storyboard.name, bundle: nil)
            let vc: T = uiStoryboard.instantiateViewController(identifier:  String(describing: self)) { (coder) -> T? in
                T(coder: coder)
            }
            
            return vc
        }
        
        return create(type: self)
    }
    
    /// Instantiate View Controller by storyboard identifier ID
    public static func instantiateVC(_ storyboard: Storyboard = .main, withId id: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.name, bundle: nil)
        let vc = uiStoryboard.instantiateViewController(withIdentifier: id)
        
        return vc
    }
    
    /// Return current ViewController identifierID
    @objc class var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController {
    private static let indicator: UIActivityIndicatorView = {
        let frame = CGRect(x: .zero, y: .zero, width: 44, height: 44)
        let indicatorView = UIActivityIndicatorView(frame: frame)
        
        return indicatorView
    }()
    private static var hudView: UIView!
    private static var bgView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    private func setupHUD() {
        Self.indicator.color = .systemBackground
        let frame = CGRect(x: (self.view.frame.width/2)-22, y: 44, width: 44, height: 44)
        // init hud
        Self.hudView = UIView(frame: frame)
        Self.hudView.backgroundColor = UIColor.darkGray
        Self.hudView.cornerRadius = frame.height/2
        Self.hudView.addSubview(Self.indicator)
        // init backgroundView
        Self.bgView.backgroundColor = .systemBackground
        Self.bgView.alpha = 0.0
        // add subView
        view.addSubview(Self.bgView)
        view.addSubview(Self.hudView)
        // animation view
        Self.hudView.transform = CGAffineTransform(translationX: 0, y: -100)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.curveEaseOut], animations: {
            Self.hudView.transform = CGAffineTransform.identity
        })
    }

    public func startIndicatorAnimate() {
        setupHUD()
        Self.indicator.startAnimating()
    }

    public func stopIndicatorAnimate() {
        Self.indicator.stopAnimating()
        
        UIView.animate(withDuration: 0.6) {
            Self.hudView.transform = CGAffineTransform(translationX: 0, y: -400)
            Self.bgView.alpha = 0.0
        } completion: { _ in
            Self.hudView.removeFromSuperview()
            Self.indicator.removeFromSuperview()
            Self.bgView.removeFromSuperview()
        }
    }
}

extension UIViewController {
    func configurationNavigationBarUI() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layoutIfNeeded()
        let attributes = [NSAttributedString.Key.font: UIFont.avenirNextMedium(size: 16), NSAttributedString.Key.foregroundColor: UIColor.heavyBlue]
        
//        navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirNextMedium(size: 30), NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    }
}

extension UIViewController {
    func registerTableViewCell(tableView: UITableView, cell: UITableViewCell.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cell.identifier)
    }
    
    func registerCollectionViewCell(collectionView: UICollectionView, cell: UICollectionViewCell.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cell.identifier)
    }
}
