//
//  UserJobberJobNumericTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/20/1400 AP.
//

import UIKit

protocol UserJobberJobNumericTableViewCellDelegate: AnyObject {
    func unitTextFieldEditingChanged(sender: UITextField, cell: UserJobberJobNumericTableViewCell)
}

class UserJobberJobNumericTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pricePerUnitLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var unitTitleLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!

    
    weak var delegate: UserJobberJobNumericTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unitTextField.becomeFirstResponder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.unitTextField.keyboardType = .asciiCapableNumberPad
        setHeavyBlueSelectedCell(selected: selected)
    }
    
    private func setHeavyBlueSelectedCell(selected: Bool) {
        unitTextField.textColor = selected ? .heavyBlue:.secondaryLabel
        unitTitleLabel.textColor = selected ? .heavyBlue:.secondaryLabel
        seperatorView.backgroundColor = selected ? .heavyBlue:.separator
    }
    
    func updateUI(serviceTitle: String, unitPrice: Double, totalPrice: Double, unitTitle: String?) {
        self.titleLabel.text = serviceTitle
        self.unitTitleLabel.text = unitTitle?.firstUppercased ?? "Per Hour".localized()
        self.pricePerUnitLabel.text = "\(unitPrice.toPriceFormatter) CHF"
        self.totalPriceLabel.text = "\(totalPrice.toPriceFormatter) CHF"
    }
    
    @IBAction func unitTextFieldEditingChanged(_ sender: Any) {
        setHeavyBlueSelectedCell(selected: true)
        delegate?.unitTextFieldEditingChanged(sender: sender as! UITextField, cell: self)
    }
}
