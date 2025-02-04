//
//  Country.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

struct Country: Hashable {
    let name: String
    let code: Int
    let image: UIImage
    
    static let countries = [Country(name: "Swiss".localized(), code: 41, image: UIImage(named: "swiss_icon")!),
                            Country(name: "France".localized(), code: 33, image: UIImage(named: "france_icon")!)]
}
