//
//  JobberProfileAuthorizeTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit

class JobberProfileAuthorizeTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(description: String, authorize: Authorize) {
        self.textLabel?.text = description
        self.backgroundColor = (authorize == Authorize.noAuthorize) ? .gray:.heavyBlue
    }
}
