//
//  JobberIdentityViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/2/1400 AP.
//

import UIKit
import RestfulAPI

class JobberIdentityTableViewController: InterfaceTableViewController {

    @IBOutlet weak var nameTextField: InsetTextField!
    @IBOutlet weak var lastnameTextField: InsetTextField!
    @IBOutlet weak var zipcodeTextField: InsetTextField!
    @IBOutlet weak var idTextField: InsetTextField!
    @IBOutlet weak var termSwitch: UISwitch!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var nextButton: AppButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        navigationItem.setHidesBackButton(true, animated: true)
        nameTextField?.becomeFirstResponder()
        termLabel.highlight(searchedText: "Terms and Conditions".localized(), color: UIColor.heavyBlue)
        
        zipcodeTextField.keyboardType = .asciiCapableNumberPad
        nameTextField.delegate = self
        lastnameTextField.delegate = self
        zipcodeTextField.delegate = self
        idTextField.delegate = self
    }
    
    private func checkIsCompleteForm() {
        func enable(_ condition: Bool) { nextButton.isOn = condition }
        
        if !nameTextField.text!.isEmpty && !lastnameTextField.text!.isEmpty && termSwitch.isOn && !zipcodeTextField.text!.isEmpty && (Int(zipcodeTextField.text!) != nil) && zipcodeTextField.text!.count == 4 {
            enable(true)
            return
        }
        
        enable(false)
    }
    
    @IBAction func textFieldEditingChanged(sender: InsetTextField) {
        checkIsCompleteForm()
    }
    
    @IBAction func termConditionSwitchValueChanged(_ sender: UISwitch) {
        checkIsCompleteForm()
    }
    
    private func registerJobberRequest(animated: Bool) {
        let name = nameTextField.text!
        let family = lastnameTextField.text!
        let zipCode = zipcodeTextField.text!
        let identifier = idTextField.text!
        let body = SendJobberRegisteration(name: name, family: family, zipCode: zipCode, identifier: identifier)
        let netowrk = RestfulAPI<SendJobberRegisteration,Generic<RCCheckOTP>>.init(path: "/jobber/register/register")
            .with(auth: .none)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(netowrk, animated: animated, disable: [nextButton]) { [weak self] (response) in
            if let token = response.data?.token {
                Auth.shared.jobber.register(with: token)
                // go to jobber vc
                let tb = UITabBarController.instantiateVC(.jobber, withId: "JobberTabBarViewController")
                UIApplication.shared.windows.first?.rootViewController = tb
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                self?.registerDeviceRequest(auth: Auth.shared.jobber)
            }
        }
    }
    
    private func checkIDAndRegisterRequest(jobberID: String) {
        struct Check: Codable { let id: String }
        let network = RestfulAPI<Check,Generic<EMPTYMODEL>>.init(path: "/jobber/register/check_available_id")
            .with(method: .POST)
            .with(body: Check(id: jobberID))
        
        handleRequestByUI(network, animated: true) { [weak self] (response) in
            guard let self = self else { return }
            if response.success { self.registerJobberRequest(animated: true) } else {
                let alertContent = AlertContent(title: .none, subject: "Inavlid ID".localized(), description: "This jobber ID is exist!".localized())
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                self.present(warningVC.prepare(warningVC.interactor),animated: true)
            }
        }
    }
    
    func registerDeviceRequest(auth: Authentication) {
        let body = SendRegisterDeviceModel(device_id: UIApplication.deviceID ?? "-", device_type: "ios", fcm: UIApplication.fcmToken, extra: UIApplication.deviceType)
        let network = RestfulAPI<SendRegisterDeviceModel,Generic<EMPTYMODEL>>.init(path: "/jobber/device/add")
            .with(auth: auth)
            .with(method: .POST)
            .with(body: body)

        handleRequestByUI(network, animated: false) { (_) in
            
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: AppButton) {
        view.endEditing(true)
        checkIDAndRegisterRequest(jobberID: idTextField.text!)
    }
}

extension JobberIdentityTableViewController: KeyboardInjection {}

extension JobberIdentityTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == zipcodeTextField {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            
            return newString.length <= maxLength
        }
        
        return true
    }
}

extension JobberIdentityTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            // term and condition
            view.endEditing(true)
            let vc = JobberTermAndConditionViewController.instantiateVC(.jobber)
            present(vc, animated: true)
        }
    }
}
