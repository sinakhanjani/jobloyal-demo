//
//  JobberPaymentTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit
import RestfulAPI

class JobberPaymentTableViewController: JobberTableViewController {

    @IBOutlet weak var saveButton: AppButton!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var paymentMethodSegmentControl: UISegmentedControl!

    public var statics: Statics?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(jobberProfileChanged(_:)), name: .jobberProfileChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if statics == nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    private func configUI() {
        title = "Payment Method".localized()
    }
    
    private func updateUI() {
        if let cardNumber = statics?.cardNumber, !cardNumber.isEmpty {
            cardNumberTextField.text = cardNumber.uppercased()
            disableCardNumberTextField()
        }
        paymentMethodSegmentControl.selectedSegmentIndex = redoPeriod()
    }
    
    private func disableCardNumberTextField() {
        cardNumberTextField.isUserInteractionEnabled = false
        cardNumberTextField.backgroundColor = .darkGray
        cardNumberTextField.isEnabled = false
    }

    private func createPeriod() -> Int {
        switch paymentMethodSegmentControl.selectedSegmentIndex {
        case 0: return 1
        case 1: return 7
        case 2: return 30
        default: return 1
        }
    }
    
    private func redoPeriod() -> Int {
        switch statics?.ponyPeriod ?? 0 {
        case 1: return 0
        case 7: return 1
        case 30: return 2
        default: return 0
        }
    }
    
    private func setPaymentRequest(iban: String, period: Int) {
        struct SendPaymentModel: Codable { let iban: String ; let period: Int }
        let network = RestfulAPI<SendPaymentModel,Generic<EMPTYMODEL>>.init(path: "/jobber/profile/edit_payment")
            .with(method: .POST)
            .with(auth: .jobber)
            .with(body: SendPaymentModel(iban: iban, period: period))
        
        self.saveButton.setTitle("Saving".localized() + "..", for: .normal)

        handleRequestByUI(network, disable: [saveButton]) { [weak self] (response) in
            guard let self = self else { return }
            
            self.disableCardNumberTextField()
            self.saveButton.setTitle("Saved".localized(), for: .normal)
            self.saveButton.backgroundColor = .heavyGreen
        }
    }
    
    @objc func jobberProfileChanged(_ notification: Notification) {
        guard let item = notification.userInfo?["jobber.profile"] as? JobberProfileModel else { return }
        
        self.statics = item.statics
        updateUI()
    }
    
    @IBAction func cardNumberValueChanged(sender: InsetTextField) {
        sender.text = sender.text?.uppercased()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        view.endEditing(true)
        setPaymentRequest(iban: cardNumberTextField.text!.uppercased(),
                          period: createPeriod())
    }
}

extension JobberPaymentTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.item == 1 {
            if let cardNumber = statics?.cardNumber, !cardNumber.isEmpty {
                let alertContent = AlertContent(title: .none, subject: "Ops!".localized(), description: "4Fa-vc1-Gj1-jkk".localized())
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)

                present(warningVC.prepare(warningVC.interactor),animated: true)
            }
        }
    }
}
