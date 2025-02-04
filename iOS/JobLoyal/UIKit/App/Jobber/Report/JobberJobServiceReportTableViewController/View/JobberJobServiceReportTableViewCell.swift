//
//  JobberJobServiceReportTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit

class JobberJobServiceReportTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(address: String, date: String, jobTitle: String, price: Double, count: Int?, unit: String?) {
        self.priceLabel.text = "\(price.toPriceFormatter)"
        self.addressLabel.text = address
        self.jobTitleLabel.text = jobTitle
        self.dateLabel.text = date
        self.countLabel.text = (unit == nil) ? "Per Hour".localized():"\(count ?? 0) \(unit!.firstUppercased)"
    }
}
