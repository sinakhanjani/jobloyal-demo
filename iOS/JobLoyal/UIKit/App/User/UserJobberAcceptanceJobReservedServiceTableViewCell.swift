//
//  UserJobberAcceptanceJobReservedServiceTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit

class UserJobberAcceptanceJobReservedServiceTableViewCell: UITableViewCell {
    
    enum Tag: String {
        case accepted
        case rejected
        case paid
        
        var value: String {
            switch self {
            case .accepted:
                return "Accepted".localized()
            case .rejected:
                return "Rejected".localized()
            case .paid:
                return "Paid".localized()
            }
        }
    }

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var pricePerUnitLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var unitValueLabel: UILabel!
    @IBOutlet weak var tagStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateUI(serviceName: String, price: Double, totalPrice: Double, unitName: String?, unitValue: String, tags: [Tag]) {
        self.unitValueLabel.text = unitValue
        self.serviceNameLabel.text = serviceName
        self.pricePerUnitLabel.text = "\(price.toPriceFormatter) CHF"
        self.unitNameLabel.text = unitName ?? "Per Hour".localized()
        self.totalPriceLabel.text = "\(totalPrice.toPriceFormatter) CHF"
        
        // add tags
        tagStackView.removeAllArrangedSubviews()
        
        tags.forEach { (tag) in
            let button = AppButton()
//            button.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                button.widthAnchor.constraint(equalToConstant: 92),
//                                            ])
            button.cornerRadius = 10
            button.setTitleColor(.white, for: .normal)
            button.isUserInteractionEnabled = false
            button.titleLabel?.font = UIFont.avenirNextMedium(size: 14)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = tag == .rejected ? .heavyRed:.heavyBlue
            button.setTitle(tag.value, for: .normal)
            
            self.tagStackView.addArrangedSubview(button)
        }
    }
}

