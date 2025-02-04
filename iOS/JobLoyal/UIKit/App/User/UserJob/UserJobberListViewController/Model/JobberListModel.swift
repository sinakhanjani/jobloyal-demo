//
//  JobberListModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/3/1400 AP.
//

import Foundation

struct SendJobberListModel: Codable {
    let latitude, longitude: Double
    let page, limit: Int
    let jobID: String
    let serviceID: String?

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, page, limit
        case jobID = "job_id"
        case serviceID = "service_id"
    }
}


// MARK: - DataClass
struct RCJobbersListModel: Codable, Hashable {
    let items: [RCJobberListModel]
}

// MARK: - Item
struct RCJobberListModel: Codable, Hashable {
    let distance: Float?
    let jobID, jobberID, identifier, avatar: String?
    let rate: String?
    let workCount: Int?

    enum CodingKeys: String, CodingKey {
        case distance
        case jobID = "job_id"
        case jobberID = "jobber_id"
        case identifier, avatar, rate
        case workCount = "work_count"
    }
}
