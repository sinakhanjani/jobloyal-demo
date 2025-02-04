//
//  SendMessageModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - UnitModel
struct SendMessageModel: Codable {
    let subject, unitModelDescription: String

    enum CodingKeys: String, CodingKey {
        case subject
        case unitModelDescription = "description"
    }
}
