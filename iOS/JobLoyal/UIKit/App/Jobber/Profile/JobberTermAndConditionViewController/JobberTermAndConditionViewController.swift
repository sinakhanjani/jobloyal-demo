//
//  JobberTermAndConditionViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/11/1400 AP.
//

import UIKit
import WebKit
import RestfulAPI

class JobberTermAndConditionViewController: JobberViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = JobberMenuItem.TermAndConditions.value
        
        JobloyalCongfiguration.TermAndCondition.isDark = traitCollection.userInterfaceStyle == .dark ? true:false
        
        if let url = URL(string: JobloyalCongfiguration.TermAndCondition.url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateUI()
        }
    }
}

