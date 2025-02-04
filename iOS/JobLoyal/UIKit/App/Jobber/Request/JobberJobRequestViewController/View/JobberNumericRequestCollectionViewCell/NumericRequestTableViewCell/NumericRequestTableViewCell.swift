//
//  NumericRequestTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit

class NumericRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(servicePrice: Double, serviceName: String, unitName: String) {
        servicePriceLabel.text = "\(servicePrice.toPriceFormatter)"
        serviceNameLabel.text = serviceName
        unitLabel.text = "Per".localized() + "\(unitName.firstUppercased)"
    }
}
