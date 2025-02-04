//
//  JobberRequestModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import Foundation

// MARK: - JobberJobsRequestModel
struct JobberJobsRequestModel: Codable, Hashable {
    var items: [JobberRequestModel]
    let requestLifeTime: Int

    enum CodingKeys: String, CodingKey {
        case items
        case requestLifeTime = "request_life_time"
    }
}

// MARK: - JobberRequestModel
struct JobberRequestModel: Codable, Hashable , Equatable {
    let id: String
    let jobTitle, price, address: String?
    let distance: Double?
    let requestLifeTime: Int?
    var remainingTime: Double
    var services: [JobberRequestServiceModel]

    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case price, address, distance
        case remainingTime = "remaining_time"
        case services
        case requestLifeTime = "request_life_time"
    }
    
    static func == (lhs: JobberRequestModel, rhs: JobberRequestModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Service
struct JobberRequestServiceModel: Codable, Hashable {
    let id: Int?
    let requestID: String?
    let unit: String?
    let price: Double
    let count: Int?
    let title: String?
    var isSelected: Bool? = false
    // for open order request:
    let totalPrice: Double?
    let accepted: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case requestID = "request_id"
        case unit, price, count, title
        // for open order request:
        case totalPrice = "total_price"
        case accepted
    }
}
