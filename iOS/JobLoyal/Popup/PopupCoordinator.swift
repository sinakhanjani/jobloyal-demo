//
//  PopupCoordinator.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import UIKit
import SwiftUI

public protocol Coordinator {
    func start()
}

public protocol PopupCoordinator: class {
    var interactor: Interactor { get set }
    var animated: Bool { get set }
}
