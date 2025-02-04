//
//  CheckOTP.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/28/1400 AP.
//

import Foundation

struct SendCheckOTP: Codable {
    let phoneNumber: String
    let code: String
}

struct SendCurrentRegion: Codable {
    let region: String
}

struct RCCheckOTP: Codable {
    let token: String
}


