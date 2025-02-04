//
//  PageViewContentController.swift
//  TEST
//
//  Created by Sina khanjani on 12/9/1399 AP.
//

import SwiftUI
import UIKit

final class PageViewContentController: UIHostingController<PageViewContent<FeatureCard>> {
    
    required init?(coder: NSCoder) {
        let models = [WalkThrought(title: "0.walkTitle-0".localized(), description: "1.walk-description-0".localized(), imageName: "0_walkthrough"),
                      WalkThrought(title: "3.walkTitle-1".localized(), description: "4.walk-description-1".localized(), imageName: "1_walkthrough".localized()),
        ]
        let pageViewContent = PageViewContent(pages: models.map { FeatureCard(walkThrought: $0) })
        
        super.init(coder: coder, rootView: pageViewContent)
        
        rootView.dismiss = dismiss
        view.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Button Action
    private func dismiss() {
        let nav = UINavigationController.instantiateVC(withId: "RegisterInitializerNavigation")
        UIApplication.shared.windows.first?.rootViewController = nav
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
