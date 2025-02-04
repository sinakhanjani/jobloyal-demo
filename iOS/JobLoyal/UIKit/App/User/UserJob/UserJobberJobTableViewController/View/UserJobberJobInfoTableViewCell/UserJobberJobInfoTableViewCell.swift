//
//  UserJobberJobInfoTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit

class UserJobberJobInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shortFullyNameLabel: UILabel!
    @IBOutlet weak var jobberIDLabel: UILabel!
    @IBOutlet weak var workedNumberLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var jobberDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rateControl.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(shortFullyName: String, jobberUsername: String, workedNumber: Int, distance: Double, commentCount: Int, rate: Double, jobberDescription: String) {
        self.shortFullyNameLabel.text = shortFullyName
        self.jobberIDLabel.text = jobberUsername.firstUppercased
        self.workedNumberLabel.text = "\(workedNumber) " + "Work".localized()
        self.distanceLabel.text = "\(Double(distance/1000).rounded(toPlaces: 2)) KM"
        self.commentNumberLabel.text = "\(commentCount) " + "Comments".localized()
        self.rateControl.rating = Int(Double(rate))
        self.jobberDescriptionLabel.text = jobberDescription.firstUppercased
    }
}
