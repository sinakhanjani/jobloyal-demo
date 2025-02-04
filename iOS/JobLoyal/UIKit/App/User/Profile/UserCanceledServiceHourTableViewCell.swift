//
//  UserCanceledServiceHourTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit

class UserCanceledServiceHourTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
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

    func updateUI(serviceName: String, price: Double, reservedDate: String, canceledBy: String) {
        serviceNameLabel.text = serviceName
        reservedDateLabel.text = reservedDate
        canceledByLabel.text = canceledBy
    }
}
