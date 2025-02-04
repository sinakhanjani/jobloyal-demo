//
//  UserRatingViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit
import RestfulAPI

class UserRatingTableViewController: UserTableViewController, UITextViewDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var jobberNameLabel: UILabel!
    @IBOutlet weak var jobberIDLabel: UILabel!
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var jobberImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    private let commentTextViewPlaceHolder = "y19-Ih1-Jh1-oi8".localized()

    public var item: UserJobberDetail?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        navigationItem.setHidesBackButton(true, animated: true)
        if let item = item {
            jobberImageView.loadImage(from: item.avatar)
            jobberNameLabel.text = "\((item.name ?? "")) \((item.family ?? ""))"
            jobberIDLabel.text = item.identifier
            // config description rate
            descriptionTextView.delegate = self
            launchTextViewUI()
        }
    }
    
    private func launchTextViewUI() {
        descriptionTextView.text = commentTextViewPlaceHolder
        descriptionTextView.textColor = .placeholderText
    }
    
    private func rateJobberRequest() {
        struct SendCommentModel: Codable { let rate: Int ; let comment: String? }

        let comment: String? = descriptionTextView.text!.isEmpty || (descriptionTextView.text == commentTextViewPlaceHolder) ? nil:descriptionTextView.text!
        let body = SendCommentModel(rate: rateControl.rating, comment: comment)
        let network = RestfulAPI<SendCommentModel, Generic<RCSendCommentModel>>.init(path: "/user/comment/submit")
            .with(method: .POST)
            .with(auth: .user)
            .with(body: body)
        
        handleRequestByUI(network, disable: [submitButton]) { [weak self] (response) in
            self?.fetchOpenOrder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == commentTextViewPlaceHolder {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            launchTextViewUI()
        }
    }
    
    @IBAction func submitButtonTapped() {
        guard rateControl.rating != 0 else {
            let alertContent = AlertContent(title: .none, subject: "Rate Jobber".localized(), description: "78J-iQ1-Kjh-pO2".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)

            present(warningVC.prepare(warningVC.interactor),animated: true)
            return
        }
        
        rateJobberRequest()
    }
}
