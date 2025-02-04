//
//  CommentTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rateControl.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(subject: String, description: String, rating: Double) {
        self.subjectLabel.text = subject
        self.descriptionLabel.text = description
        self.rateControl.rating = Int(Double(rating))
    }
}
