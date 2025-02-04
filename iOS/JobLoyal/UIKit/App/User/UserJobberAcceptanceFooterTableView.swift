//
//  UserJobberAcceptancePhoneFooterTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit

class UserJobberAcceptanceFooterTableView: UIView {
    
    enum State {
        case verify
        case call
    }
    
    var state: State = .call
    
    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.cornerRadius = 0
        
        return view
    }()
    
    let payButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        button.cornerRadius = 24
        
        return button
    }()
    
    init(height: CGFloat, state: State) {
        self.state = state
        super.init(frame: CGRect(x: .zero, y: .zero, width: .zero, height: height))
        
        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(payButton)
            
        payButton.setTitle((state == .call) ? "":"Verify (pay price to jobber)".localized()
                           , for: .normal)
        payButton.backgroundColor = (state == .call) ? .heavyBlue: .heavyGreen

        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),

            // payButton constraint:
            payButton.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 8),
            payButton.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            payButton.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            payButton.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -8),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //
    }
}
