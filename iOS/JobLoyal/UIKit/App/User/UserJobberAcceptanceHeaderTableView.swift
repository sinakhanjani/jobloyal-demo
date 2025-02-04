//
//  UserJobberAcceptanceHeaderTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit

class UserJobberAcceptanceHeaderTableView: UIView {
    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .heavyBlue
        view.cornerRadius = 0
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.avenirNextMedium(size: 17)
        label.numberOfLines = 2
        label.text = "".localized()
        label.textAlignment = .left
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.avenirNextMedium(size: 14)
        label.numberOfLines = 2
        label.text = "May after jobber cancel your request".localized()
        label.textAlignment = .left
        
        return label
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.avenirNextMedium(size: 42)
        label.numberOfLines = 1
        label.text = ""
        label.textAlignment = .center
        
        return label
    }()
    
    init(height: CGFloat) {
        super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: height))
        
        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(descriptionLabel)
        bgView.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            // titleLabel constraint:
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -8),

            // descriptionLabel constraint:
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: timerLabel.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -8),

            // timerLabel constraint:
            timerLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 8),
            timerLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            timerLabel.widthAnchor.constraint(equalToConstant: 120),

        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
