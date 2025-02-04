//
//  UserReservedServiceHourTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit

class UserReservedServiceHourTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
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

    func updateUI(serviceName: String, price: Double, time: String, jobberName: String, reservedDate: String) {
        timeLabel.text = time
        serviceNameLabel.text = serviceName
        jobberNameLabel.text = jobberName
        reservedDateLabel.text = reservedDate
    }
}
