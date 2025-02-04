//
//  ServiceTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit

protocol ServiceTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(cell: ServiceTableViewCell)
}

class ServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    weak var delegate: ServiceTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(name: String, unitName: String?, price: Double) {
        self.nameLabel.text = name.firstUppercased
        self.unitLabel.text = (unitName == nil) ? "Per Hour".localized(): "Per".localized() + " \(unitName!.firstUppercased)"
        self.priceLabel.text = "\(price.toPriceFormatter) CHF"
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.deleteButtonTapped(cell: self)
    }
}
