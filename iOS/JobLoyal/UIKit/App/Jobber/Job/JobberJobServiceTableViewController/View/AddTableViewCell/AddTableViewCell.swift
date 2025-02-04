//
//  AddTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit

protocol AddTableViewCellDelegate: AnyObject {
    func addServiceButtonTapped()
}

class AddTableViewCell: UITableViewCell {
    
    weak open var delegate: AddTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addServiceButtonTapped() {
        delegate?.addServiceButtonTapped()
    }
}
