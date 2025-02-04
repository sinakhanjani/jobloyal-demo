//
//  JobberAuthenticateTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit
import RestfulAPI

class JobberAuthenticateTableViewController: JobberTableViewController {
    
    @IBOutlet weak var cameraImageUploadButton: UIButton!
    @IBOutlet weak var photoLibraryImageUploadButton: UIButton!

    var imagePickerController = UIImagePickerController()
    
    public var jobberProfile: JobberProfileModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Authentication".localized()
        updateImagePicker(.photoLibrary)
    }
    
    private func uploadAvatarRequest(data: Data) {
        struct RCUploadModel: Codable { let url: String }
        let file = File(key: "doc", data: data)
        let netowrk = RestfulAPI<File,Generic<RCUploadModel>>.init(path: "/jobber/register/upload_doc")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: file)
        
        handleRequestByUI(netowrk, disable: [cameraImageUploadButton, photoLibraryImageUploadButton]) { [weak self] (respone) in
            guard let self = self else { return }
            
            if self.imagePickerController.sourceType == .camera {
                self.cameraImageUploadButton.setTitle("Document Submitted".localized(), for: .normal)
            } else {
                self.photoLibraryImageUploadButton.setTitle("Document Submitted".localized(), for: .normal)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    @IBAction func photoGalleryButtonTapped(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 1: updateImagePicker(.camera)
        case 2: updateImagePicker(.photoLibrary)
        default: break
        }
    }
}

extension JobberAuthenticateTableViewController: ImportPhotoInjection {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickupImage = info[.originalImage] as? UIImage else { return }
        guard let data = pickupImage.jpegData(compressionQuality: 0.1) else { return }
        
        if imagePickerController.sourceType == .camera {
            self.cameraImageUploadButton.backgroundColor = .heavyGreen
            self.cameraImageUploadButton.setTitle("Sending Document".localized(), for: .normal)
        } else {
            self.photoLibraryImageUploadButton.backgroundColor = .heavyGreen
            self.photoLibraryImageUploadButton.setTitle("Sending Document".localized(), for: .normal)
        }
        
        self.uploadAvatarRequest(data: data)
        picker.dismiss(animated: true, completion: nil)
    }
}
