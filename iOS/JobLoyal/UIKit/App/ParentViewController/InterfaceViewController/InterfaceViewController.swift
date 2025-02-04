//
//  ViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/11/1399 AP.
//

import UIKit
import RestfulAPI

class InterfaceViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        configurationNavigationBarUI()
        view.backgroundColor = .systemGroupedBackground
    }
}

class InterfaceTableViewController: BaseTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        configurationNavigationBarUI()
        view.backgroundColor = .systemGroupedBackground
    }
}
