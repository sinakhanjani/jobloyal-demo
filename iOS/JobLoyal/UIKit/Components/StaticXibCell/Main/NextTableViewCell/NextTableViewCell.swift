//
//  NextTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

class NextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nextButton: AppButton!
    
    var nextButtonTappedHandler: ((_ cell: NextTableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        nextButtonTappedHandler?(self)
    }
}
