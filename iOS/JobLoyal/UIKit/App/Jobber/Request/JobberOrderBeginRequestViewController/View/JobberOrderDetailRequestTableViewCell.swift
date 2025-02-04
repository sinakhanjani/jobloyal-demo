//
//  JobberOrderDetailRequestTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit

class JobberOrderDetailRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var underPriceLabel: UILabel!
    @IBOutlet weak var underTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func updateUI(time: String, price: String, underPriceName: String, underTimeName: String, name: String?) {
        self.timeLabel.text = time
        self.priceLabel.text = price.toDouble()!.toPriceFormatter + " CHF"
        self.underPriceLabel.text = underPriceName
        self.underTimeLabel.text = underTimeName
        
        if let name = name { self.nameLabel.text = name }
    }
}
