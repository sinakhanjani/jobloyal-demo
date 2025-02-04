//
//  ShadowView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
//

import UIKit

class ShadowView: RoundedView {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        super.setupLayer()
    }
}
