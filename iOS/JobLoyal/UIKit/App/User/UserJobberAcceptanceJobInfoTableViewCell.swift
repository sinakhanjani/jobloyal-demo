//
//  UserJobberAcceptanceJobInfoTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit

class UserJobberAcceptanceJobInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var jobberNameLabel: UILabel!
    @IBOutlet weak var jobberIDLabel: UILabel!
    @IBOutlet weak var workNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var recieveTimeLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var jobberImageView: UIImageView!
    @IBOutlet weak var rateControl: STRatingControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rateControl.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(jobberName: String, jobberID: String, workNumber: Int, commentNumber: Int, receiveTime: String, imageURL: String, rate: Double) {
        self.jobberIDLabel.text = jobberID
        self.jobberNameLabel.text = jobberName
        self.workNumberLabel.text = "\(workNumber) " + "Work".localized()
        self.commentNumberLabel.text = "\(commentNumber) " + "comment".localized()
        self.rateControl.rating = Int(Double(rate))
        self.rateLabel.text = "\(rate)"
        self.jobberImageView.loadImage(from: imageURL)
        self.recieveTimeLabel.text = receiveTime
    }
    
}
