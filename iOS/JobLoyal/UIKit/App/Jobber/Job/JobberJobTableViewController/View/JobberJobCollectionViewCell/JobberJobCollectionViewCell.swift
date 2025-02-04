//
//  JobberServiceCollectionViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/3/1400 AP.
//

import UIKit

protocol JobberJobCollectionViewCellDelegate: AnyObject {
    func onlineButtonTapped(cell: JobberJobCollectionViewCell)
    func offlineButtonTapped(cell: JobberJobCollectionViewCell)
    func serviceAndCommentsGestureTapped(cell: JobberJobCollectionViewCell)
}

class JobberJobCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var availableView: AvailableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var timelineLabel: UILabel!
    @IBOutlet weak var serviceAndCommentStackView: UIStackView!
    @IBOutlet weak var onlineButton: UIButton!
    @IBOutlet weak var offlineButton: UIButton!

    weak open var delegate: JobberJobCollectionViewCellDelegate?
    public var isAvailable: Bool = false {
        willSet {
            // uppdate available view
            availableView.alpha = newValue ? 1:0
            availableView.cornerRaduis(corners: [.bottomLeft,
                                                 .topRight]
                                       , radius: 18)
            // update buttons when status changed
            onlineButton.alpha = newValue ? 0.34:1
            offlineButton.alpha = newValue ? 1:0.34
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(serviceAndCommentsGestureTapped))
        serviceAndCommentStackView.addGestureRecognizer(tapGesture)
    }
    
    func updateUI(title: String, numberOfSerivce: String, timeLine: String?) {
        titleLabel.text = title
        numberLabel.text = numberOfSerivce + " " + "Service".localized()
        updateTimeLineUI(timeLine: timeLine)
    }
    
    func updateTimeLineUI(timeLine: String?) {
        if let timeLine = timeLine, let time = timeLine.to(date: "HH:mm") {
            timelineLabel.text = "Today be online at".localized() + " \(time)"
        } else {
            timelineLabel.text = "Job is not active".localized()
        }
    }
    
    @objc func serviceAndCommentsGestureTapped() {
        delegate?.serviceAndCommentsGestureTapped(cell: self)
    }

    @IBAction func onlineButtonTapped(_ sender: Any) {
        delegate?.onlineButtonTapped(cell: self)
    }

    @IBAction func offlineButtonTapped(_ sender: Any) {
        delegate?.offlineButtonTapped(cell: self)
    }
}
