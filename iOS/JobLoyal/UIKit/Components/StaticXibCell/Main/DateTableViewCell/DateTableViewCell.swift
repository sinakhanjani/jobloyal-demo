//
//  DateTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

class DateTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        // Configure the view for the selected state
    }
    
    func updateUI(date: Date) {
        datePicker.date = date
    }
}
