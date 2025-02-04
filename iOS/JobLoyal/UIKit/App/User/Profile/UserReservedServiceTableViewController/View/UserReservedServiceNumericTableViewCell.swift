//
//  UserReservedServiceTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit

class UserReservedServiceNumericTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var reservedDateLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var jobberNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(serviceName: String, price: Double, unitName: String, unitValue: String, jobberName: String, reservedDate: String) {
        unitLabel.text = unitValue
        serviceNameLabel.text = serviceName
        unitNameLabel.text = unitName
        totalPriceLabel.text = "\(price.toPriceFormatter) CHF"
        jobberNameLabel.text = jobberName
        reservedDateLabel.text = reservedDate
    }
}
