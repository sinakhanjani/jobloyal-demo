//
//  ReportJobModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/30/1400 AP.
//

import Foundation

// MARK: - ReportsJobModel
struct ReportsJobModel: Codable, Hashable {
    let items: [ReportJobModel]?
}

// MARK: - ReportJobModel
struct ReportJobModel: Codable, Hashable {
    let id,jobTitle, status, createdAt, address, tag: String?

    enum CodingKeys: String, CodingKey {
        case jobTitle = "job_title"
        case status
        case createdAt = "created_at"
        case address
        case tag
        case id
    }
}

// MARK: - SendReportModel
struct SendReportModel: Codable {
    let page: Int
    let limit: Int
}
