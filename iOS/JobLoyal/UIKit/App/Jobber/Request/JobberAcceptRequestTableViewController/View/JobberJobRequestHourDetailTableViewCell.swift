//
//  JobberJobRequestHourDetailTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit

class JobberJobRequestHourDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(jobName: String, distance: String, addressName: String) {
        self.jobNameLabel.text = jobName
        if let distance = Double(distance)?.rounded(toPlaces: 2) {
            self.distanceLabel.text = "\(distance) KM"
        }
        addressNameLabel.text = addressName
    }
}
