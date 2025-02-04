//
//  JenderTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

class GenderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)
        // Configure the view for the selected state
    }
    
    func configUI(title: String) {
        textLabel?.text = title
    }
    
    func updateUI(title: String) {
        textLabel?.text = title
    }
}
