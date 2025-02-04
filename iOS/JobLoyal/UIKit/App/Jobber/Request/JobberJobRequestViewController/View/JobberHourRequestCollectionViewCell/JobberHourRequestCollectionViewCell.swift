//
//  JobberHourRequestCollectionViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit

class JobberHourRequestCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    
    weak open var buttonDelegate: JobberRequestCollectionViewCellButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(remainingTime: Int, item: JobberRequestServiceModel?, jobName: String, distance: Double, totalPrice: Double, address: String) {
        let elapsedTimeInSecond = remainingTime
        let seconds = elapsedTimeInSecond % 60
        let minutes = (elapsedTimeInSecond / 60) % 60
        let secendText = String(format: "%02d", seconds)
        let minuteText = String(format: "%02d", minutes)
        
        rejectButton.setTitle("Reject".localized() + " \(minuteText):\(secendText)", for: .normal)

        addressLabel.text = address
        jobNameLabel.text = jobName
        distanceLabel.text = "\(Double(distance/1000).rounded(toPlaces: 2)) KM"
        nextButton.setTitle("Next".localized() + " \(totalPrice) CHF", for: .normal)
        
        if let item = item {
            unitNameLabel.text = "Per Hour".localized()
            servicePriceLabel.text = "\(item.price.toPriceFormatter)"
            serviceNameLabel.text = item.title
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        buttonDelegate?.nextButtonTapped(cell: self)
    }
    
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        buttonDelegate?.rejectButtonTapped(cell: self)
    }
}
