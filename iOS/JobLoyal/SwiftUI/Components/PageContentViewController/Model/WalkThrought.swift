//
//  WalkThrought.swift
//  TEST
//
//  Created by Sina khanjani on 12/10/1399 AP.
//

import SwiftUI

class WalkThrought {
    private let imageName: String
    public var image: Image { Image(imageName) }
    
    public let title: String
    public let description: String
    
    init(title: String, description: String, imageName: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}
