//
//  JobberSuspendView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/6/1400 AP.
//
import UIKit

class JobberSuspendView: UIView {
        
    let inboxImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bad_face_Icon")!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = UIColor.label
        
        return imageView
    }()
    
    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.avenirNextMedium(size: 24)
        label.cornerRadius = 18
        label.numberOfLines = 1
        label.text = "Your account is suspend !".localized()
        label.textAlignment = .center
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.avenirNextMedium(size: 17)
        label.cornerRadius = 18
        label.numberOfLines = 6
        label.text = ""
        label.textAlignment = .center
        
        return label
    }()
    
    init(frame: CGRect, detail: String) {
        super.init(frame: frame)
        self.descriptionLabel.text = detail
        
        backgroundColor = .clear
        
        addSubview(bgView)
        bgView.addSubview(inboxImageView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            bgView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            bgView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            bgView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            bgView.heightAnchor.constraint(equalToConstant: 240),
            
            // inboxImageView constraint:
            inboxImageView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 32),
            inboxImageView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor, constant: 0),
            inboxImageView.widthAnchor.constraint(equalToConstant: 100),
            inboxImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // titleLabel constraint:
            titleLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: inboxImageView.bottomAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            
            // descriptionLabel constailet
            descriptionLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),
            descriptionLabel.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 140),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
}
