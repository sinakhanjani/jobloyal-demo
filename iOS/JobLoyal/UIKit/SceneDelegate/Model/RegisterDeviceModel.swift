//
//  File.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/31/1400 AP.
//

import Foundation

struct SendRegisterDeviceModel: Codable {
    let device_id, device_type, fcm, extra: String
}
