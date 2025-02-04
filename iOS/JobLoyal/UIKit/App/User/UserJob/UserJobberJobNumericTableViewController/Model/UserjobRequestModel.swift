//
//  SendJobRequestModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/4/1400 AP.
//

import Foundation

// MARK: - UserjobRequestModel
struct SendUserjobRequestModel: Codable {
    let latitude, longitude: Double
    let jobberID: String
    let services: [SendServiceRequestModel]

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case jobberID = "jobberId"
        case services
    }
}

// MARK: - Service
struct SendServiceRequestModel: Codable {
    let id: String
    let count: Int?
}




// MARK: - DataClass
struct RCUserjobRequestModel: Codable {
    let items: [RCServiceRequestModel]?
    let requestLifeTime: Int?

    enum CodingKeys: String, CodingKey {
        case items
        case requestLifeTime = "request_life_time"
    }
}

// MARK: - Item
struct RCServiceRequestModel: Codable {
    let price, count: Double
    let accepted: Bool
    let serviceID, requestID: String

    enum CodingKeys: String, CodingKey {
        case price, count, accepted
        case serviceID = "service_id"
        case requestID = "request_id"
    }
}
