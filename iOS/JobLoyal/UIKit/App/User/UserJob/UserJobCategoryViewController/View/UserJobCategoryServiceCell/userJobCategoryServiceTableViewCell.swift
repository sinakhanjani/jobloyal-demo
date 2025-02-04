//
//  userJobCategoryServiceTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit

class userJobCategoryServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceTitleLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(categoryTitle: String, jobTitle: String, serviceTitle: String) {
        serviceTitleLabel.text = serviceTitle.firstUppercased
        jobTitleLabel.text = jobTitle.firstUppercased
        categoryTitleLabel.text = categoryTitle.firstUppercased
    }
}
