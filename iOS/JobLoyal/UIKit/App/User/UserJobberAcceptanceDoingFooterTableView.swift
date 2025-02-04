//
//  UserJobberAcceptanceDoingFooterTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit

class UserJobberAcceptanceDoingFooterTableView: UIView {
    
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
        label.font = UIFont.avenirNextMedium(size: 19)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Doing".localized() + " ...".localized()
        
        return label
    }()

    init(height: CGFloat) {
        super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: height))
        
        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(titleLabel)
  
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),

            // payButton constraint:
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
