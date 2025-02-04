//
//  SendUserRegisteration.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - SendUserRegisteration
struct SendUserRegisteration: Codable {
    let name, family, gender, email: String
    let address, birthday: String
}
