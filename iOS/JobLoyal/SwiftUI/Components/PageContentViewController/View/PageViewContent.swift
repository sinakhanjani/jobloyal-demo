//
//  PageViewContent.swift
//  TEST
//
//  Created by Sina khanjani on 12/9/1399 AP.
//

import SwiftUI

struct PageViewContent<Page: View>: View {
    
    var pages: [Page] = []
    var dismiss: onTappedHandler!

    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: DEFAULT_SIZE_04) {
            ZStack(alignment: .bottom) {
                PageViewController(pages: pages, currentPage: $currentPage)
                    .background(Color(UIColor.systemGroupedBackground))
                
                CustomButton(title: "Get Started".localized(), image: nil, buttonTapped: dismiss)
                    .background(Color.heavyBlue)
                    .cornerRadius(DEFAULT_RADIUS_16)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color(UIColor.systemGroupedBackground))

            }
            .background(Color(UIColor.systemGroupedBackground))

            PageControl(numberOfPages: pages.count, currentPage: $currentPage)
                .frame(width: CGFloat(pages.count * 18))
                .background(Color(UIColor.systemGroupedBackground))

        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        let models = [WalkThrought(title: "Relax and Repair", description: "keep calm and relax with this app you can do your work and only with one click repair broken things", imageName: "0_walkthrough"),WalkThrought(title: "Relax and Repair", description: "keep calm and relax with this app you can do your work and only with one click repair broken things", imageName: "0_walkthrough")]
        PageViewContent(pages: models.map { FeatureCard(walkThrought: $0) }, dismiss: {})
            .preferredColorScheme(.light)
    }
}
