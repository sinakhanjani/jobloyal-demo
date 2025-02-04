//
//  TermTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

class TermTableViewCell: UITableViewCell {

    @IBOutlet weak var termSwitch: UISwitch!
    @IBOutlet weak var termLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        termLabel.highlight(searchedText: "Terms and Conditions".localized(), color: UIColor.heavyBlue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }
    
    func updateUI(isOn: Bool) {
        termSwitch.isOn = isOn
    }
}
