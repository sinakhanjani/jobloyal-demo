//
//  JobberCompleteProfileTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit
import RestfulAPI

class JobberCompleteProfileTableViewController: JobberTableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var aboutusTextView: UITextView!
    @IBOutlet weak var saveButton: AppButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageUploadButton: UIButton!

    private var gender: Gender = .none {
        willSet { genderLabel.text = newValue.value }
    }
    
    var imagePickerController = UIImagePickerController()
    var pickupImage: UIImage?

    public var jobberProfile: JobberProfileModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    private func configUI() {
        title = "Complete Profile".localized()
        updateImagePicker(.photoLibrary)
        aboutusTextView.delegate = self
    }
    
    private func updateUI() {
        if let jobberProfile = jobberProfile {
            emailTextField.text = jobberProfile.email?.firstUppercased
            addressTextField.text = jobberProfile.address?.firstUppercased
            aboutusTextView.text = jobberProfile.aboutUs?.firstUppercased
            if let gender = jobberProfile.gender {
                self.gender = gender ? .men:.women
            } else {
                self.gender = .none
            }
            
            checkIsCompleteForm()
        }
    }
    
    private func uploadAvatarRequest(data: Data) {
        struct RCUploadModel: Codable { let url: String }
        let file = File(key: "avatar", data: data)
        let netowrk = RestfulAPI<File,Generic<RCUploadModel>>.init(path: "/jobber/register/upload_avatar")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: file)
        
        handleRequestByUI(netowrk, animated: true) { [weak self] (respone) in
            guard let self = self else { return }
            
            self.imageUploadButton.setTitle("Photo Uploaded".localized(), for: .normal)
            self.saveButton.setTitle("Saved".localized(), for: .normal)
            self.saveButton.backgroundColor = .heavyGreen
        }
    }
    
    private func updateProfileRequest() {
        view.endEditing(true)

        struct SendProfileModel: Codable { let email: String; let address: String; let about_us: String; let gender: Bool; let birthday: String }
        
        let birthday = datePicker.date.toString(format: "YYYY-MM-dd")
        let body = SendProfileModel(email: emailTextField.text!, address: addressTextField.text!, about_us: aboutusTextView.text!, gender: gender == .men ? true:false, birthday: birthday)
        
        UIView.animate(withDuration: 0.4) {
            if let _ = self.pickupImage {
                self.imageUploadButton.setTitle("Uploading Photo".localized(), for: .normal)

            }
            self.saveButton.setTitle("Saving".localized() + "..", for: .normal)
        }

        let network = RestfulAPI<SendProfileModel,Generic<EMPTYMODEL>>.init(path: "/jobber/register/complete_profile")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: body)

        handleRequestByUI(network, disable: [saveButton]) { [weak self] (response) in
            guard let self = self else { return }
            if let pickupImageData = self.pickupImage?.jpegData(compressionQuality: 0.1) {
                self.uploadAvatarRequest(data: pickupImageData)
            } else if response.success == true {
                self.saveButton.setTitle("Saved".localized(), for: .normal)
                self.saveButton.backgroundColor = .heavyGreen
            } else {
                self.saveButton.setTitle("Save".localized(), for: .normal)
                self.saveButton.backgroundColor = .heavyBlue
            }
        }
    }
    
    private func checkIsCompleteForm() {
        func enable(_ condition: Bool) { saveButton.isOn = condition }

        if (!emailTextField.text!.isEmpty) && (!addressTextField.text!.isEmpty) && (gender != .none), (emailTextField.text!.isValidEmail == true), (aboutusTextView.text!.isEmpty == false) {
            enable(true)
            return
        }
        
        enable(false)
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: AppButton) {
        present(imagePickerController, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: AppButton) {
        guard pickupImage != nil else {
            let alertContent = AlertContent(title: .none, subject: "UploadPhoto".localized(), description: "bodyPhotoUploaded".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)

            present(warningVC.prepare(warningVC.interactor),animated: true)
            return
        }
        updateProfileRequest()
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        checkIsCompleteForm()
    }
}

extension JobberCompleteProfileTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let nc = UINavigationController.instantiateVC(withId: "GenderNavigationViewController") as! UINavigationController
            if let vc = nc.viewControllers.first as? GenderViewController {
                vc.delegate = self
                present(nc, animated: true)
            }
        }
    }
}

extension JobberCompleteProfileTableViewController: GenderViewControllerDelegate {
    func selected(gender: Gender) {
        self.gender = gender
        checkIsCompleteForm()
    }
}

extension JobberCompleteProfileTableViewController: ImportPhotoInjection {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickupImage = info[.originalImage] as? UIImage else { return }
        
        self.imageUploadButton.backgroundColor = .heavyGreen
        self.imageUploadButton.setTitle("Photo Selected".localized(), for: .normal)
        self.pickupImage = pickupImage
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension JobberCompleteProfileTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkIsCompleteForm()
    }
}
