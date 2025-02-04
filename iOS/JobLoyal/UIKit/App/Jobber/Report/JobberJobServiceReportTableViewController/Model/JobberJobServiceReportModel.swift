//
//  JobberJobServiceReportModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/31/1400 AP.
//

import Foundation

// MARK: - JobberJobServiceReportModel
struct JobberJobServiceReportModel: Codable, Hashable {
    let id, status, createdAt, address: String?
    let services: [JobberRequestServiceModel]?

    enum CodingKeys: String, CodingKey {
        case id, status
        case createdAt = "created_at"
        case address, services
    }
}
