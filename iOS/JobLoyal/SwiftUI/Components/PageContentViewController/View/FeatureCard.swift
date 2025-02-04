//
//  FeatureCard.swift
//  TEST
//
//  Created by Sina khanjani on 12/9/1399 AP.
//

import SwiftUI

struct FeatureCard: View {
    var walkThrought: WalkThrought
    
    var body: some View {
        VStack(spacing: DEFAULT_PADDING_00) {
            walkThrought.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(TextOverlay())
            
            Text(walkThrought.title)
                .font(.avenirNext(size: DEFAULT_SIZE_24, relativeTo: .title))
                .fontWeight(.semibold)
//                .padding()
            
            Text(walkThrought.description)
                .font(.avenirNext(size: DEFAULT_SIZE_16, relativeTo: .caption))
                .fontWeight(.regular)
                .foregroundColor(Color.secondary)
                .padding()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct TextOverlay: View {
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
        }
        .foregroundColor(.white)
    }
}

struct FeatureCard_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCard(walkThrought: WalkThrought(title: "Relax and Repair", description: "keep calm and relax with this app you can do your work and only with one click repair broken things", imageName: "0_walkthrough"))
    }
}
