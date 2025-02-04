//
//  UserJobberJobNumericFooterTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/20/1400 AP.
//

import UIKit

class UserJobberJobNumericOrHourFooterTableViewSection: UIView {
    
    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.cornerRadius = 0
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 17)
        label.numberOfLines = 1
        label.text = "What do this step?".localized()
        label.textAlignment = .left
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.avenirNextMedium(size: 14)
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .left
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            // titleLabel constraint:
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 0),
            
            // descriptionLabel constraint:
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
