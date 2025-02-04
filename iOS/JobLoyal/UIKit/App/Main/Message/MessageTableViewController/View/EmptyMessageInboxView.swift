//
//  EmptyMessageInboxView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/13/1400 AP.
//

import UIKit

class EmptyMessageInboxView: UIView {
    
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
        label.text = "The Message Box is Empty".localized()
        label.textAlignment = .center
        
        return label
    }()
    
    let ticketButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create New Ticket".localized(), for: .normal)
        button.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        button.cornerRadius = 24
        button.backgroundColor = .heavyBlue
        button.isEnabled = true
        button.isUserInteractionEnabled = true

        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(inboxImageView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(ticketButton)
        
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
            
            // ticketButton constraint:
            ticketButton.centerXAnchor.constraint(equalTo: bgView.centerXAnchor, constant: 0),
            ticketButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ticketButton.widthAnchor.constraint(equalToConstant: 200),
            ticketButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
