//
//  AddMessageTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/13/1400 AP.
//

import UIKit
import RestfulAPI

protocol AddMessageTableViewControllerDelegate: AnyObject {
    func ticketAdded()
}

class AddMessageTableViewController: JobberTableViewController {
    
    @IBOutlet weak var sendButton: AppButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var subjectTextField: InsetTextField!
    
    public var auth: Authentication = .none
    public weak var delegate: AddMessageTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func checkAuth() {
        auth = Authentication.user.isLogin ? .user:.jobber
    }
    
    func sendMessageRequest() {
        checkAuth()
        guard auth != .none else { return }
        let path = auth == .jobber ? "jobber":"user"
        let body = SendMessageModel(subject: subjectTextField.text!, unitModelDescription: descriptionTextView.text!)
        let network = RestfulAPI<SendMessageModel,Generic<EMPTYMODEL>>.init(path: "/\(path)/message/send")
            .with(auth: auth)
            .with(method: .POST)
            .with(body: body)
        
        self.view.endEditing(true)
        handleRequestByUI(network, disable: [sendButton]) { [weak self] (response) in
            if response.success {
                self?.delegate?.ticketAdded()
                self?.sendButton.backgroundColor = .heavyGreen
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func updateUI() {
        title = "Send Message".localized()
        descriptionTextView.delegate = self
    }
    
    private func checkIsCompleteForm() {
        func enable(_ condition: Bool) { sendButton.isOn = condition }

        if !subjectTextField.text!.isEmpty && !descriptionTextView.text!.isEmpty {
            enable(true)
            return
        }
        
        enable(false)
    }
    
    @IBAction func textFieldValueChanged(_ sender: Any) {
        checkIsCompleteForm()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        sendMessageRequest()
    }
}

extension AddMessageTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkIsCompleteForm()
    }
}
