//
//  JobberProfileTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit

protocol JobberProfileTableViewCellDelegate: AnyObject {
    func imageGestureTapped()
}

class JobberProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profileImageView: CircleImageView!
    
    weak open var delegate: JobberProfileTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func imageGestureTapped() {
        delegate?.imageGestureTapped()
    }
    
    private func configUI() {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageGestureTapped))
        profileImageStackView.addGestureRecognizer(imageTapGesture)
    }

    func updateUI(name: String, id: String, phone: String, imageURL: String?) {
        nameLabel.text = name
        phoneLabel.text = phone
        idLabel.text = id
        // update profileImage
        if let imageURL = imageURL, !imageURL.isEmpty {
            profileImageView.loadImage(from: imageURL)
        } else {
            profileImageView.image = UIImage(systemName: "questionmark.circle.fill")
        }
    }
    
    func updateImage(image: UIImage) {
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.image = image
    }
}
