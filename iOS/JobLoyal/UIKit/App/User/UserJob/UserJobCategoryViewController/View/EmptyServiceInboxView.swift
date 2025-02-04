//
//  EmptyServiceInboxView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/8/1400 AP.
//

import UIKit

class EmptyServiceInboxView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 17)
        label.cornerRadius = 18
        label.numberOfLines = 2
        label.text = "Nothing found".localized() + " !"
        label.textAlignment = .center
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // titleLabel constraint:
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}

