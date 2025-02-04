//
//  AlertContentViewController.swift
//  TEST
//
//  Created by Sina khanjani on 12/9/1399 AP.
//

import SwiftUI
import UIKit
//import Popup

final class AlertContentViewController: UIHostingController<AlertContentView>, PopupConfiguration {
    
    internal var interactor: Interactor = Interactor()
    
    public var yesButtonTappedHandler: (() ->Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: AlertContentView())
        rootView.dismiss = dismiss
        rootView.yesButton = yesButtonTapped

        view.backgroundColor = .clear
    }
    
    /// Add your custom alert message type as 'AlertContent'.
    public func alert(_ alertContent: AlertContent) -> Self {
        rootView.alertContentModelData = AlertContentModelData(alertContent: alertContent)
        
        return self
    }

    private func dismiss() {
        dismiss(animated: true)
    }
    
    private func yesButtonTapped() {
        dismiss()
        yesButtonTappedHandler?()
    }
}
