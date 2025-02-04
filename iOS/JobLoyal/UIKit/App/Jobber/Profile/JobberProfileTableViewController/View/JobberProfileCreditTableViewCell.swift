//
//  JobberProfileCreditTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit

class JobberProfileCreditTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(price: Double) {
        self.priceLabel.text = "\(price.toPriceFormatter)"
    }
}
