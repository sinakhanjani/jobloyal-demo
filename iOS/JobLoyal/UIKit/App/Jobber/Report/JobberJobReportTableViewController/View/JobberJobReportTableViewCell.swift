//
//  JobberJobReportTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit

class JobberJobReportTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(address: String, date: String, jobTitle: String, tag: String) {
        let acceptedTitle = "accepted".uppercased().localized()
        self.tagButton.setTitle( (tag == "accepted") ? acceptedTitle:tag.uppercased(), for: .normal)
        self.tagButton.backgroundColor = (tag == "accepted") ? .heavyBlue:.darkGray
        self.addressLabel.text = address
        self.jobTitleLabel.text = jobTitle
        self.dateLabel.text = date
    }
}
