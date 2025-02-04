//
//  DetailTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var doneJobLabel: UILabel!
    @IBOutlet weak var allRequestsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(totalIncome: Double, doneJob: Int, allRequests: Int) {
        self.totalIncomeLabel.text = "\(totalIncome.toPriceFormatter) CHF"
        self.doneJobLabel.text = "\(doneJob)"
        self.allRequestsLabel.text = "\(allRequests)"
    }
}
