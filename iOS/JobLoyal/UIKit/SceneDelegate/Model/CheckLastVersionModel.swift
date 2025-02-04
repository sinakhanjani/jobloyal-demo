//
//  CheckLastVersionModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/31/1400 AP.
//

import Foundation

// MARK: - SendCheckLastVersionModel
struct SendCheckLastVersionModel: Codable {
    let device_type: String
    let is_jobber_app: Bool
}
// MARK: - DataClass
struct RCCheckLastVersionModel: Codable {
    let id: Int
    let deviceType: String?
    let isJobberApp: Bool?
    let dataDescription: String?
    let force: Bool?
    let link: String?
    let versionCode: Int?
    let createdAt, updatedAt: String?
    let period: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case deviceType = "device_type"
        case isJobberApp = "is_jobber_app"
        case dataDescription = "description"
        case force, link
        case versionCode = "version_code"
        case createdAt, updatedAt
        case period
    }
}
