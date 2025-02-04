//
//  KeyboardInjection.swift
//  Nerkh
//
//  Created by Sina khanjani on 1/19/1399 AP.
//  Copyright © 1399 Sina Khanjani. All rights reserved.
//

import UIKit

protocol KeyboardInjection: AnyObject {

}

extension KeyboardInjection {
    func configureKeyboard<T: UIScrollView>(with collection: T) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { [unowned self = self] notification in
            self.keyboardWasShown(notification as NSNotification, collection: collection)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [unowned self = self] notification in
            self.keyboardWasShown(notification as NSNotification, collection: collection)
        }
    }

    func keyboardWasShown<T: UIScrollView>(_ notificiation: NSNotification, collection: T) {
        guard let info = notificiation.userInfo,
            let keyboardFrameValue =
            info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
            else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        collection.contentInset = contentInsets
        collection.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillBeHidden<T: UIScrollView>(_ notification: NSNotification, collection: T) {
        let contentInsets = UIEdgeInsets.zero
        collection.contentInset = contentInsets
        collection.scrollIndicatorInsets = contentInsets
    }
}
