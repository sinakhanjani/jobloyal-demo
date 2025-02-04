//
//  UserJobberJobTableHeaderView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/21/1400 AP.
//

import UIKit

class UserJobberJobTableHeaderView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 17)
        label.numberOfLines = 1
        label.text = ""
        label.textAlignment = .left
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.avenirNextMedium(size: 14)
        label.numberOfLines = 2
        label.text = ""
        label.textAlignment = .left
        
        return label
    }()


    init(title: String, body: String) {
        super.init(frame: CGRect())

        backgroundColor = .clear
        
        titleLabel.text = title
        descriptionLabel.text = body
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            // titleLabel constraint:
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            // descriptionLabel constraint:
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
