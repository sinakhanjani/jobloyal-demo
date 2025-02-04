//
//  JobberLocationStatus.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct JobberLocationStatus: Codable {
    let id: Int
    let jobberID, location, address, createdAt: String?
    let shouldUpdate: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case jobberID = "jobber_id"
        case location, address, createdAt, shouldUpdate
    }
}
