//
//  CreateJobberServiceModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - CreateJobberServiceModel
struct SendCreateJobberServiceModel: Codable {
    let title: String
    let unitID: String?
    let jobID: String

    enum CodingKeys: String, CodingKey {
        case title
        case unitID = "unit_id"
        case jobID = "job_id"
    }
}

// MARK: - DataClass
struct RCCreateJobberServiceModel: Codable {
    let id, title, creatorUserID, defaultUnitID: String?
    let jobID, updatedAt, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case creatorUserID = "creator_user_id"
        case defaultUnitID = "default_unit_id"
        case jobID = "job_id"
        case updatedAt, createdAt
    }
}
