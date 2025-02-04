//
//  UserJobCategoryHeaderTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/18/1400 AP.
//

import UIKit

class UserJobCategoryHeaderTableView: UIView {
    
    public var isExpanded: Bool = false {
        willSet {
            func transform(_ transform: CGAffineTransform) {
                inboxImageView.transform = transform
            }

            let identityTransform = CGAffineTransform.identity
            let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)

            UIView.animate(withDuration: 0.3) {
                newValue ? transform(rotationTransform):transform(identityTransform)
            }
        }
    }
    
    let inboxImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right.circle")!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = UIColor.label
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 17)
        label.cornerRadius = 18
        label.numberOfLines = 1
        label.text = "What service do you need?".localized()
        label.textAlignment = .left
        
        return label
    }()

    init(height: CGFloat) {
        super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: height))

        backgroundColor = .clear
        
        addSubview(inboxImageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // inboxImageView constraint:
            inboxImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            inboxImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            inboxImageView.widthAnchor.constraint(equalToConstant: 22),
            inboxImageView.heightAnchor.constraint(equalToConstant: 22),
            
            // titleLabel constraint:
            titleLabel.leadingAnchor.constraint(equalTo: inboxImageView.trailingAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
