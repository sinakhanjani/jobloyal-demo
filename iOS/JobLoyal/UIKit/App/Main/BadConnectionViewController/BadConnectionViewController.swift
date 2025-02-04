//
//  JobloyalUIViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/2/1400 AP.
//

import UIKit

class BadConnectionViewController: UIViewController {
    
    static var isPresented: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BadConnectionViewController.isPresented = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BadConnectionViewController.isPresented = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            let reachability = Reachability()
            guard case .online(_) = reachability.connectionStatus() else { return }
            self?.dismiss(animated: true)
        })
    }
    
    deinit {
        BadConnectionViewController.isPresented = false
    }
}
