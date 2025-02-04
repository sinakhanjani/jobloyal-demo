//
//  JobberAcceptRequestTimerTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit

protocol JobberAcceptRequestTimerTableViewCellDelegate: class {
    func didSelect(minute: Int)
}

class JobberAcceptRequestTimerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timePickerView: UIPickerView!
    
    private let minutes: [Int] = [5,10,15,30,45,60]
    
    weak var delegate: JobberAcceptRequestTimerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    private func configUI() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension JobberAcceptRequestTimerTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        minutes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(minutes[row].toString()) " + "Minute".localized()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let minute = minutes[row]
        delegate?.didSelect(minute: minute)
    }
}
