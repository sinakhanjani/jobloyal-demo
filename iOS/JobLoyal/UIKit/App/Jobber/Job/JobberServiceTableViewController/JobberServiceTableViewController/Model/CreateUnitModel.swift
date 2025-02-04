//
//  CreateUnitModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// RCCreateUnitModel: - DataClass
struct RCCreateUnitModel: Codable {
    let id, title, updatedAt, createdAt: String?
    let createdNew: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, updatedAt, createdAt
        case createdNew = "created_new"
    }
}
