//
//  UserEditProfileTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit
import RestfulAPI

class UserEditProfileTableViewController: UserTableViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameTextField: InsetTextField!
    @IBOutlet weak var lastnameTextField: InsetTextField!
    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var addressTextField: InsetTextField!
    @IBOutlet weak var nextButton: AppButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var lastnameCell: UITableViewCell!
    @IBOutlet weak var genderCell: UITableViewCell!
    @IBOutlet weak var birthdayCell: UITableViewCell!
    
    private var gender: Gender = .none {
        willSet { genderLabel.text = newValue.value }
    }
    
    private let formatter = DateFormatter()
    
    public var item: UserProfileModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if item == nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileChanged(_:)), name: .userProfileChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    private func configUI() {
        title = "Update Profile".localized()
        // update labels
        nameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
        addressTextField.delegate = self
    }
    
    private func updateUI() {
        guard let item = self.item else { return }
        nameTextField.text = item.name?.firstUppercased
        lastnameTextField.text = item.family?.firstUppercased
        emailTextField.text = item.email?.firstUppercased
        addressTextField.text = item.address?.firstUppercased
        gender = (item.gender ?? false) ? .men:.women
        
        formatter.dateFormat = "YYYY-MM-dd"
        let birthdayDate = (item.birthday ?? "").to(date: "YYYY-MM-dd") ?? ""
        if let date = formatter.date(from: birthdayDate) {
            datePicker.date = date
        }
        
        disableEnteredField(item: item)
        checkIsCompleteForm()
    }
    
    private func disableEnteredField(item: UserProfileModel) {
        func disable(cell: UITableViewCell, item: Any?) {
            if item != nil {
                cell.backgroundColor = .darkGray
                cell.isUserInteractionEnabled = false
            }
        }
        
        disable(cell: nameCell, item: item.name)
        disable(cell: lastnameCell, item: item.family)
        disable(cell: genderCell, item: item.gender)
        disable(cell: birthdayCell, item: item.birthday)
        datePicker.tintColor = .white
    }
    
    private func updateProfileRequest(with body: SendUserEditProfileModel) {
        view.endEditing(true)
        nextButton.setTitle("Saving".localized() + "..", for: .normal)
        
        let network = RestfulAPI<SendUserEditProfileModel,Generic<EMPTYMODEL>>.init(path: "/user/profile/edit")
            .with(method: .POST)
            .with(auth: .user)
            .with(body: body)

        handleRequestByUI(network, disable: [nextButton, deleteAccountButton]) { [weak self] _ in
            self?.nextButton.setTitle("Saved".localized(), for: .normal)
            self?.nextButton.backgroundColor = .heavyGreen
        }
    }
    
    private func checkIsCompleteForm() {
        func enable(_ condition: Bool) { nextButton.isOn = condition }
        
        if !nameTextField.text!.isEmpty && !lastnameTextField.text!.isEmpty && gender != .none{
            enable(true)
            return
        }
        
        enable(false)
    }
    
    func userDeleteAccountRequest() {
        let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/user/delete-account")
            .with(auth: .user)
            .with(method: .POST)
            
        handleRequestByUI(network) { response in
            if response.success == true {
                Auth.shared.user.logout()
                let nav = UINavigationController
                    .instantiateVC(withId: "RegisterInitializerNavigation")
                UIApplication.shared.windows.first?.rootViewController = nav
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }
    
    func userDeleteAccount() {
        let alertContent = AlertContent(title: .none, subject: "Delete Account".localized(), description: "Do you want to delete your account? All your data will be deleted".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)

        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.userDeleteAccountRequest()
        }
        
        present(alertVC.prepare(alertVC.interactor), animated: true)
    }
    
    @objc func userProfileChanged(_ notification: Notification) {
        guard let item = notification.userInfo?["user.profile"] as? UserProfileModel else { return }
        self.item = item
        updateUI()
    }
    
    @IBAction func textFieldEditingChanged(sender: InsetTextField) {
        checkIsCompleteForm()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        checkIsCompleteForm()
    }
    
    @IBAction func nextButtonTapped(_ sender: AppButton) {
        let name = nameTextField.text!
        let family = lastnameTextField.text!
        let email = emailTextField.text!
        let address = addressTextField.text!
        let birthday = datePicker.date.toString(format: "YYYY-MM-dd")
        let sendUserEditProfileModel = SendUserEditProfileModel(name: name, family: family, gender: gender.isMen, email: email, address: address, birthday: birthday)
        
        updateProfileRequest(with: sendUserEditProfileModel)
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        userDeleteAccount()
    }
}

extension UserEditProfileTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            let nc = UINavigationController.instantiateVC(withId: "GenderNavigationViewController") as! UINavigationController
            
            if let vc = nc.viewControllers.first as? GenderViewController {
                vc.delegate = self
                present(nc, animated: true)
            }
        }
    }
}

extension UserEditProfileTableViewController: KeyboardInjection {}

extension UserEditProfileTableViewController: GenderViewControllerDelegate {
    func selected(gender: Gender) {
        self.gender = gender
        checkIsCompleteForm()
    }
}

extension UserEditProfileTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        return true
    }
}

extension UserEditProfileTableViewController: DateFormaterInjection { }
