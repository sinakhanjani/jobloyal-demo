//
//  UserJobberJobNextStepView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/20/1400 AP.
//

import UIKit

class UserJobberJobNextStepView: UIView {

    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .heavyBlue
        view.cornerRadius = 24
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.avenirNextMedium(size: 17)
        label.cornerRadius = 18
        label.numberOfLines = 1
        label.text = ""
        label.textAlignment = .left
        
        return label
    }()
    
    let nextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.avenirNextMedium(size: 19)
        label.numberOfLines = 1
        label.text = "Next Step".localized()
        label.textAlignment = .right
        
        return label
    }()

    init(height: CGFloat) {
        super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: height))

        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(nextLabel)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            // titleLabel constraint:
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: nextLabel.leadingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),
            
            // nextLabel constraint:
            nextLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            nextLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),
            nextLabel.heightAnchor.constraint(equalToConstant: 34),
            nextLabel.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
