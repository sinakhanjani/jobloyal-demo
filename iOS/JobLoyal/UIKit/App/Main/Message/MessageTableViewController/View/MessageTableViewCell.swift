//
//  MessageTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/13/1400 AP.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagButton.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(isAnswered: Bool, title: String, date: String) {
        self.titleLabel.text = title.firstUppercased
        self.dateLabel.text = date
        
        let tagButtonTitle = isAnswered ? "Answered".localized():"Question".localized()
        let tagButtonColor = isAnswered ? UIColor.heavyGreen:UIColor.darkGray
        
        tagButton.backgroundColor = tagButtonColor
        tagButton.setTitle(tagButtonTitle, for: .normal)
    }
}
