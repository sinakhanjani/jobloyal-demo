//
//  ImportPhotoInjection.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/11/1400 AP.
//

import UIKit

protocol ImportPhotoInjection: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePickerController: UIImagePickerController { get set }
    func updateImagePicker(_ sourceType: UIImagePickerController.SourceType)
}


extension ImportPhotoInjection {
    func updateImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
    }
}
