//
//  JobberAcceptRequestTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/7/1400 AP.
//

import UIKit

class JobberAcceptRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var serviceTitlelabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var unitTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(serviceName: String, unitName: String?, price: Double) {
        self.serviceTitlelabel.text = serviceName
        self.priceLabel.text = "\(price.toPriceFormatter)"

        if let unitname = unitName?.firstUppercased {
            self.unitTitleLabel.text = "Per " + unitname
        } else { self.unitTitleLabel.text = "Per Hour" }
    }
}
