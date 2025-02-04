//
//  UserAcceptJobModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/4/1400 AP.
//

import Foundation

// MARK: - UserAcceptJobModel
struct UserAcceptJobModel: Codable, Hashable {
    var jobID, status, arrivalTime: String?
    let timeBase: Bool?
    let page: UserJobberPageModel?
    let remainingTime: Int?
    let services: [ServiceModel]?
    let comments: [CommentModel]?
    let totalPay: Double?
    let userTimePaying: Int?
    let totalTimeInvertal: Int?
    
    enum CodingKeys: String, CodingKey {
        case jobID = "job_id"
        case status
        case arrivalTime = "arrival_time"
        case timeBase = "time_base"
        case page
        case remainingTime = "remaining_time"
        case services, comments
        case totalPay = "total_pay"
        case userTimePaying = "user_time_paying"
        case totalTimeInvertal = "total_time_interval"
    }
}

// MARK: - UserJobberPageModel
struct UserJobberPageModel: Codable, Hashable {
    let id, name, identifier: String?
    let avatar: String?
    let aboutMe, phoneNumber, rate: String?
    let workCount, totalComments: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, identifier, avatar
        case aboutMe = "about_me"
        case phoneNumber = "phone_number"
        case rate
        case workCount = "work_count"
        case totalComments = "total_comments"
    }
}

// MARK: - Service
struct ServiceModel: Codable, Hashable {
    let title: String?
    let count: Int?
    let price, totalPrice: Double?
    let accepted: Bool
    let unit: String?
    let requestID: String?
    let isPaid: Bool?

    enum CodingKeys: String, CodingKey {
        case title, count, price
        case totalPrice = "total_price"
        case accepted, unit
        case requestID = "request_id"
        case isPaid = "is_paid"
    }
}
