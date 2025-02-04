//
//  UserIdentityViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import UIKit
import RestfulAPI

class UserIdentityTableViewController: InterfaceTableViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameTextField: InsetTextField!
    @IBOutlet weak var lastnameTextField: InsetTextField!
    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var addressTextField: InsetTextField!
    @IBOutlet weak var nextButton: AppButton!
    @IBOutlet weak var termSwitch: UISwitch!
    
    private let toGenderViewControllerSegue = "toGenderViewControllerSegue"
    private var gender: Gender = .none {
        willSet { genderLabel.text = newValue.value }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        navigationItem.setHidesBackButton(true, animated: true)
        nameTextField?.becomeFirstResponder()
        termLabel.highlight(searchedText: "Terms and Conditions".localized(), color: UIColor.heavyBlue)
        
        nameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
        addressTextField.delegate = self
    }
    
    private func checkIsCompleteForm() {
        func enable(_ condition: Bool) { nextButton.isOn = condition }
        
        if !nameTextField.text!.isEmpty && !lastnameTextField.text!.isEmpty && gender != .none && termSwitch.isOn {
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
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        checkIsCompleteForm()
    }
    
    @IBAction func nextButtonTapped(_ sender: AppButton) {
        guard emailTextField.text!.isValidEmail else {
            let alertContent = AlertContent(title: .none, subject: "Invalid Email Address".localized(), description: "Please enter the correct email address".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(warningVC.prepare(warningVC.interactor),animated: true)
            
            return
        }
        
        view.endEditing(true)
        
        let name = nameTextField.text!
        let family = lastnameTextField.text!
        let email = emailTextField.text!
        let address = addressTextField.text!
        let birthday = datePicker.date.toString(format: "YYYY-MM-dd")
        let body = SendUserRegisteration(name: name, family: family, gender: gender.isMen, email: email, address: address, birthday: birthday)
        let netowrk = RestfulAPI<SendUserRegisteration,Generic<RCCheckOTP>>.init(path: "/user/register/register")
            .with(auth: .none)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(netowrk, disable: [nextButton]) { [weak self] (response) in
            if let token = response.data?.token {
                Auth.shared.user.register(with: token)
                // go to jobber vc
                let nav = UINavigationController.instantiateVC(.user, withId: "UserFindJobNavigationController")
                UIApplication.shared.windows.first?.rootViewController = nav
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                self?.registerDeviceRequest(auth: Authentication.user)
            }
        }
        
        print(name,family,email,address)
    }
    
    func registerDeviceRequest(auth: Authentication) {
        let path = auth == .jobber ? "jobber":"user"
        let body = SendRegisterDeviceModel(device_id: UIApplication.deviceID ?? "SIMULATOR", device_type: "ios", fcm: UIApplication.fcmToken, extra: UIApplication.deviceType)
        let network = RestfulAPI<SendRegisterDeviceModel,Generic<EMPTYMODEL>>.init(path: "/\(path)/device/add")
            .with(auth: auth)
            .with(method: .POST)
            .with(body: body)

        handleRequestByUI(network, animated: false) { (response) in
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toGenderViewControllerSegue {
            let genderNavigationViewController = segue.destination as! UINavigationController
            let genderViewController = genderNavigationViewController.viewControllers.first as! GenderViewController
            genderViewController.delegate = self
        }
    }
}

extension UserIdentityTableViewController: KeyboardInjection {}

extension UserIdentityTableViewController: GenderViewControllerDelegate {
    func selected(gender: Gender) {
        self.gender = gender
        checkIsCompleteForm()
    }
}

extension UserIdentityTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        return true
    }
}

extension UserIdentityTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 6 {
            // term and condition
            view.endEditing(true)
            let vc = UserTermAndConditionViewController.instantiateVC(.user)
            present(vc, animated: true)
        }
    }
}
