//
//  UserJobberJobServiceHourTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit

class UserJobberJobServiceHourTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(title: String, price: Double) {
        self.titleLabel.text = title
        self.priceLabel.text = "\(price.toPriceFormatter) CHF"
    }
}
