//
//  JobberJobServiceModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct JobberJobDetailModel: Codable, Hashable {
    let requestCount: Int?
    let totalComments: Int?
    let workCount: Int?
    let totalIncome: String?
    let rate: String?
    let services: [JobberJobServiceModel]?

    enum CodingKeys: String, CodingKey {
        case requestCount = "request_count"
        case totalComments = "total_comments"
        case workCount = "work_count"
        case totalIncome = "total_income"
        case rate, services
    }
}

// MARK: - Service
struct JobberJobServiceModel: Codable, Hashable {
    let id, title: String
    let price: Double
    let unit: String?
}
