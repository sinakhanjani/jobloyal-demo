//
//  WarningContentViewController.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import SwiftUI
import UIKit

final class VersionContentViewController: UIHostingController<VersionContentView> {
        
    public var yesButtonTappedHandler: (() ->Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: VersionContentView())
        rootView.yesButton = yesButtonTapped

        view.backgroundColor = .secondarySystemBackground
        view.alpha = 0.9
    }
    
    /// Add your custom alert message type as 'AlertContent'.
    public func alert(_ alertContent: AlertContent) -> Self {
        rootView.alertContentModelData = AlertContentModelData(alertContent: alertContent)
        
        return self
    }
    
    private func yesButtonTapped() {
        // open safari.
        yesButtonTappedHandler?()
    }
}
