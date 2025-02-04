//
//  ReservedService.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/5/1400 AP.
//

import Foundation

// MARK: - DataClass
struct RCReservedServicesModel: Codable {
    let items: [ReservedServiceModel]
}

// MARK: - Item
struct ReservedServiceModel: Codable, Hashable {
    let id: String?
    let title: String?
    let count: String?
    let price: String?
    let jobberName: String?
    let unit: String?
    let reservedAt: String?
    let totalTime: String?

    enum CodingKeys: String, CodingKey {
        case id, title, count, price
        case jobberName = "jobber_name"
        case unit
        case reservedAt = "reserved_at"
        case totalTime = "total_time"
    }
}
