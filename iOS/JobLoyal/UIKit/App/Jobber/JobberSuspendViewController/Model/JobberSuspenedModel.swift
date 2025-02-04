//
//  JobberSuspenedModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/31/1400 AP.
//

import Foundation

// MARK: - JobberSuspenedModel
struct RCJobberSuspenedModel: Codable {
    let id: Int?
    let reason, userID, expired: String?
    let finite, system: Bool?
    let updatedAt, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, reason
        case userID = "user_id"
        case expired, finite, system, updatedAt, createdAt
    }
}

