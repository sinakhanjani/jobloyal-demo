//
//  TicketButtonTableFooterView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/13/1400 AP.
//

import UIKit

class TicketButtonTableFooterView: UIView {
    
    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
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
        bgView.addSubview(ticketButton)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bgView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            bgView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            // ticketButton constraint:
            ticketButton.centerXAnchor.constraint(equalTo: bgView.centerXAnchor, constant: 0),
            ticketButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0),
            ticketButton.widthAnchor.constraint(equalToConstant: 200),
            ticketButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
