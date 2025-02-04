//
//  JobberJobServiceTableFooterView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/9/1400 AP.
//

import UIKit

class JobberJobServiceTableFooterView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 17)
        label.numberOfLines = 1
        label.text = "Job Services".localized()
        label.textAlignment = .left
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.avenirNextMedium(size: 14)
        label.numberOfLines = 2
        label.text = "You should add every service that you can do in this job".localized()
        label.textAlignment = .left
        
        return label
    }()


     init() {
        super.init(frame: CGRect())

        backgroundColor = .clear
        
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
