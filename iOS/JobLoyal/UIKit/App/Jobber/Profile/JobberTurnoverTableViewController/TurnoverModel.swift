//
//  TurnoverModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 5/2/1400 AP.
//

import Foundation

// MARK: - TurnoversModel
struct TurnoversModel: Codable, Hashable {
    let items: [Turnover]?
}

// MARK: - Turnover
struct Turnover: Codable, Hashable {
    let id, jobberID, amount, status: String?
    let refCode, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case jobberID = "jobber_id"
        case amount, status
        case refCode = "ref_code"
        case createdAt, updatedAt
    }
}
