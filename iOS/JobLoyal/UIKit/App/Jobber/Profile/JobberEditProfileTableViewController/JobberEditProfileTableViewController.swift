//
//  EditProfileTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit
import RestfulAPI

class JobberEditProfileTableViewController: JobberTableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var aboutusTextView: UITextView!
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var savedButton: AppButton!
    @IBOutlet weak var deleteAccountButton: UIButton!

    var imagePickerController = UIImagePickerController()
    var pickupImage: UIImage?
    
    public var jobberProfile: JobberProfileModel?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(jobberProfileChanged(_:)), name: .jobberProfileChanged, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        updateImagePicker(.photoLibrary)
        title = "Update Profile".localized()
        if let jobberProfile = jobberProfile {
            self.emailTextField.text = jobberProfile.email?.firstUppercased
            self.addressTextField.text = jobberProfile.address?.firstUppercased
            self.aboutusTextView.text = jobberProfile.aboutUs?.firstUppercased
        }
    }
    
    private func uploadAvatarRequest(data: Data) {
        struct RCUploadModel: Codable { let url: String }
        let file = File(key: "avatar", data: data)
        let netowrk = RestfulAPI<File,Generic<RCUploadModel>>.init(path: "/jobber/register/upload_avatar")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: file)
        
        handleRequestByUI(netowrk, disable: [savedButton, deleteAccountButton]) { [weak self] (respone) in
            guard let self = self else { return }
            
            self.imageUploadButton.setTitle("Photo Uploaded".localized(), for: .normal)
            self.savedButton.setTitle("Saved".localized(), for: .normal)
            self.savedButton.backgroundColor = .heavyGreen
        }
    }
    
    private func updateProfileRequest() {
        view.endEditing(true)
        
        struct SendProfileModel: Codable { let email: String ; let address: String ; let about_us: String }
        let body = SendProfileModel(email: self.emailTextField.text!, address: self.addressTextField.text!, about_us: self.aboutusTextView.text!)
        let network = RestfulAPI<SendProfileModel,Generic<EMPTYMODEL>>.init(path: "/jobber/profile/update")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: body)
        
        UIView.animate(withDuration: 0.4) {
            if let _ = self.pickupImage {
                self.imageUploadButton.setTitle("Updating Profile".localized(), for: .normal)
            }
            self.savedButton.setTitle("Saving".localized() + "..", for: .normal)
        }
        
        handleRequestByUI(network, disable: [savedButton, deleteAccountButton]) { [weak self] (response) in
            guard let self = self else { return }
            if let pickupImageData = self.pickupImage?.jpegData(compressionQuality: 0.1) {
                self.uploadAvatarRequest(data: pickupImageData)
            } else {
                self.savedButton.setTitle("Saved".localized(), for: .normal)
                self.savedButton.backgroundColor = .heavyGreen
            }
        }
    }

    func jobberDeleteAccountRequest() {
        let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/jobber/delete-account")
            .with(auth: .jobber)
            .with(method: .POST)
            
        handleRequestByUI(network) { response in
            if response.success == true {
                let nav = UINavigationController
                    .instantiateVC(withId: "RegisterInitializerNavigation")
                UIApplication.shared.windows.first?.rootViewController = nav
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                // logout from server token
                Auth.shared.jobber.logout()
                // remove reminder notification
                JobloyalCongfiguration.Notification.dailyUpdateJob.unschedule()
                JobloyalCongfiguration.Notification.dailyUpdateJobStatus = true
            }
        }
    }
    
    func jobberDeleteAccount() {
        let alertContent = AlertContent(title: .none, subject: "Delete Account".localized(), description: "Do you want to delete your account? All your data will be deleted".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)

        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.jobberDeleteAccountRequest()
        }
        
        present(alertVC.prepare(alertVC.interactor), animated: true)
    }
    
    @objc func jobberProfileChanged(_ notification: Notification) {
        guard let item = notification.userInfo?["jobber.profile"] as? JobberProfileModel else { return }
        jobberProfile = item
        updateUI()
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: AppButton) {
        present(imagePickerController, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: AppButton) {
        guard self.emailTextField.text!.isValidEmail else {
            let alertContent = AlertContent(title: .none, subject: "Invalid Email".localized(), description: "Please enter the correct email address".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(warningVC.prepare(warningVC.interactor), animated: true)
            return
        }
        guard !self.emailTextField.text!.isEmpty && !self.addressTextField.text!.isEmpty && !self.aboutusTextView.text.isEmpty else {
            let alertContent = AlertContent(title: .none, subject: "Empty field".localized(), description: "One of the update profile fields is empty".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(warningVC.prepare(warningVC.interactor), animated: true)
            return
        }
        
        updateProfileRequest()
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        jobberDeleteAccount()
    }
}

extension JobberEditProfileTableViewController: ImportPhotoInjection {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickupImage = info[.originalImage] as? UIImage else { return }
        self.imageUploadButton.backgroundColor = .heavyGreen
        self.imageUploadButton.setTitle("Photo Selected".localized(), for: .normal)
        self.pickupImage = pickupImage
        picker.dismiss(animated: true, completion: nil)
    }
}
