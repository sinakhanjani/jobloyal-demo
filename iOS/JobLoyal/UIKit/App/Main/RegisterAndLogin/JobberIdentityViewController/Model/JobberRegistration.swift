//
//  JobberRegistration.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - JobberRegisteration
struct SendJobberRegisteration: Codable {
    let name, family, zipCode, identifier: String

    enum CodingKeys: String, CodingKey {
        case name, family
        case zipCode = "zip_code"
        case identifier
    }
}


