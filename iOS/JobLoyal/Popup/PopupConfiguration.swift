//
//  PresentingPopupViewController.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit

public protocol PopupConfiguration: UIViewController {
    var interactor: Interactor { get set }
    func prepare(_ interactor: Interactor, animated: Bool) -> Self
}

public extension PopupConfiguration {
    func prepare(_ interactor: Interactor ,animated: Bool = true) -> Self {
        self.view.backgroundColor = .clear
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .overFullScreen
        self.interactor = interactor
        
        return self
    }
}
