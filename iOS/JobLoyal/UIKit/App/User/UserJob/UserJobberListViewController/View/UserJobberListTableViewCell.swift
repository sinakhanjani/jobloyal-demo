//
//  UserJobberListTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit

class UserJobberListTableViewCell: UITableViewCell {
    @IBOutlet weak var shortFullyNameLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var workedNumberLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var suggestionButton: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        suggestionButton.isEnabled = false
        rateControl.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(shortFullyName: String, jobberID: String, distance: Float, rate: String, workedNumber: Int , isSuggested: Bool) {
        self.shortFullyNameLabel.text = shortFullyName
        self.IDLabel.text = jobberID.firstUppercased
        self.workedNumberLabel.text = "\(workedNumber) " + "Worked".localized()
        self.distanceLabel.text = "\(Double(distance/1000).rounded(toPlaces: 2)) KM"
        self.suggestionButton.alpha = isSuggested ? 1:0
        self.rateControl.rating = Int(Double(rate) ?? 0.0)
    }

}
