//
//  JobberTurnoverTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit

class JobberTurnoverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(title: String, date: String, price: String, status: String) {
        titleLabel.text = title
        dateLabel.text = date
        priceLabel.text = "\(price) CHF"
        switch status {
        case "pending", "queue":
            imageView?.image = UIImage(systemName: "checkmark.rectangle")
            break // 1
        case "success":
            imageView?.image = UIImage(systemName: "checkmark.rectangle.fill")
            break // 2
        case "failed":
            imageView?.image = UIImage(systemName: "minus")
            break // X
        default:
            break
        }
    }
    
    func changeLabelColor(_ color: UIColor) {
        titleLabel.textColor = color
        dateLabel.textColor = color
        priceLabel.textColor = color
        statusImageView.tintColor = color
    }
}
