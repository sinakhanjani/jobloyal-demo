//
//  CancelServiceModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/5/1400 AP.
//

import Foundation

// MARK: - DataClass
struct RCCancelServicesModel: Codable {
    let items: [CancelServiceModel]
}

// MARK: - CancelServiceModel
struct CancelServiceModel: Codable, Hashable {
    let id: String?
    let title: String?
    let count: String?
    let price: String?
    let jobberName: String?
    let unit: String?
    let reservedAt: String?
    let status: String?
    let canceledBy: String?
    let totalTime: String?

    enum CodingKeys: String, CodingKey {
        case id, title, count, price
        case jobberName = "jobber_name"
        case unit
        case reservedAt = "reserved_at"
        case status
        case canceledBy = "cancled_by"
        case totalTime = "total_time"
    }
}
