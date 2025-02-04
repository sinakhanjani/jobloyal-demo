//
//  EmptyReservedInboxView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/6/1400 AP.

import UIKit

class EmptyReservedInboxView: UIView {
    
    let inboxImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "archivebox")!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = UIColor.label
        
        return imageView
    }()
    
    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 24)
        label.cornerRadius = 18
        label.numberOfLines = 1
        label.text = "The Reserved List is Empty".localized()
        label.textAlignment = .center
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(inboxImageView)
        bgView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bgView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            bgView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            // inboxImageView constraint:
            inboxImageView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 32),
            inboxImageView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor, constant: 0),
            inboxImageView.widthAnchor.constraint(equalToConstant: 54),
            inboxImageView.heightAnchor.constraint(equalToConstant: 54),
            
            // titleLabel constraint:
            titleLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: inboxImageView.bottomAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
