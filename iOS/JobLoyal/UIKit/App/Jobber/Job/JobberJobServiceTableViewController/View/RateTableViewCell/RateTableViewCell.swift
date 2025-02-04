//
//  RateTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit

protocol RateTableViewCellDelegate: AnyObject {
    func commentButtonTapped()
}

class RateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    @IBOutlet weak var ratingControl: STRatingControl!

    weak open var delegate: RateTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingControl.isUserInteractionEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(commentsButtonTapped(_:)))
        commentStackView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(from: Int, averageRate: Double) {
        fromLabel.text = "From".localized() + " \(from)"
        averageRateLabel.text = "\(averageRate)"
        ratingControl.rating = Int(averageRate)
    }
    
    @objc func commentsButtonTapped(_ sender: Any) {
        delegate?.commentButtonTapped()
    }
}
