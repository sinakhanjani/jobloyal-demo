//
//  UserCanceledServiceNumericTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit

class UserCanceledServiceNumericTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var reservedDateLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var canceledByLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(serviceName: String, price: Double, unitName: String, unitValue: String, reservedDate: String, canceledBy: String) {
        unitLabel.text = unitValue
        serviceNameLabel.text = serviceName
        unitNameLabel.text = unitName
        reservedDateLabel.text = reservedDate
        canceledByLabel.text = canceledBy
    }
}
