//
//  TextFieldTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: InsetTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configUI(placeholder: String) {
        self.textField.placeholder = placeholder
    }
    
    public func updateUI(text: String) {
        self.textField.text = text
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        
        return true
    }
}
