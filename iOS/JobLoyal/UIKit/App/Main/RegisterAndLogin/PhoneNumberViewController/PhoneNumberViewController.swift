//
//  PhoneNumberViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import UIKit
import RestfulAPI

class PhoneNumberViewController: InterfaceViewController {

    @IBOutlet weak var countyView: CountryView!
    @IBOutlet weak var phoneTextField: InsetTextField!
    @IBOutlet weak var nextButton: AppButton!
    
    private let phoneFormat: [Character] = ["X", "X", " ", "X", "X", "X", " ", "X", "X", " ", "X", "X"]
    
    private let toVerificationViewControllerSegue = "toVerificationViewControllerSegue"
    private let toCountryViewControllerSegue = "toCountryViewControllerSegue"
    
    private var country: Country = Country.countries[0] {
        willSet {
            countyView.imageView.image = newValue.image
            countyView.codeLabel.text = "+\(newValue.code)"
        }
    }
    
    public var auth: Authentication = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    // MARK: METHOD
    private func updateUI() {
        phoneTextField.keyboardType = .asciiCapableNumberPad
        phoneTextField.becomeFirstResponder()
    }
    
    private func formatPhone(_ number: String) -> String {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        var result = ""
        var index = cleanNumber.startIndex
        for ch in phoneFormat {
            if index == cleanNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        return result
    }
    
    // MARK: IBACTION
    @IBAction func nextButtonTapped(_ sender: Any) {
        let phoneNumber = "+\(country.code)" + phoneTextField.text!
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        let sendOTP = SendOTP(phoneNumber: phoneNumber)
        let network = RestfulAPI<SendOTP,Generic<EMPTYMODEL>>.init(path: "/common/otp/send")
            .with(method: .POST)
            .with(body: sendOTP)

        handleRequestByUI(network, disable: [nextButton]) { [weak self] (response) in
            guard let self = self else { return }
            self.performSegue(withIdentifier: self.toVerificationViewControllerSegue, sender: nil)
        }
    }
    
    @IBAction func phoneNumberValueChanged(sender: InsetTextField) {
        func enable(_ condition: Bool) {
            nextButton.isOn = condition
            if condition { view.endEditing(true) }
        }
        
        sender.text = formatPhone(sender.text!)
        sender.text!.count == phoneFormat.count ? enable(true): enable(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toCountryViewControllerSegue {
            let destination = segue.destination as! UINavigationController
            let countryViewController = destination.viewControllers.first as! CountryViewController
            
            countryViewController.delegate = self
        }
        if segue.identifier == toVerificationViewControllerSegue {
            let verificationViewController = segue.destination as! VerificationViewController
            let phoneNumber = "+\(country.code)" + phoneTextField.text!
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            verificationViewController.phoneNumber = phoneNumber
            verificationViewController.auth = auth
        }
    }
}

extension PhoneNumberViewController: CountryViewControllerDelegate {
    func selected(country: Country) {
        self.country = country
    }
}
