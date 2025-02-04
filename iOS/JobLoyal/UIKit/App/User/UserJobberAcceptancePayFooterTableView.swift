//
//  UserJobberAcceptancePayFooterTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit

class UserJobberAcceptancePayFooterTableView: UIView {
    
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
        label.textColor = .heavyBlue
        label.font = UIFont.avenirNextMedium(size: 21)
        label.numberOfLines = 1
        label.text = ""
        label.textAlignment = .left
        
        return label
    }()
    
    let payButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .heavyBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        button.setTitle("Next and Pay".localized(), for: .normal)
        button.cornerRadius = 24
        
        return button
    }()

    init(heigh: CGFloat) {
        super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: heigh))

        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(payButton)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            
            // titleLabel constraint:
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),
            
            // payButton constraint:
            payButton.heightAnchor.constraint(equalToConstant: 48),
            payButton.widthAnchor.constraint(equalToConstant: 168),
            payButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),
            payButton.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
