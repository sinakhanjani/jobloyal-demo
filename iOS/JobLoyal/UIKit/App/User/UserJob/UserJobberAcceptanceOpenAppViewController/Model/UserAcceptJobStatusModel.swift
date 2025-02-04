//
//  UserAcceptJobStatusModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/4/1400 AP.
//

import Foundation

struct UserAcceptJobStatusModel: Codable {
    let requestID, status, createdAt: String?
    let remainingTime: Int?
    let jobTitle: String?
    let jobber: UserJobberDetail?
    let serviceCount: String?
    let requestLifeTime, userTimePaying: Int?
    let tag: String?
    let totalPay: Double?
    
    enum CodingKeys: String, CodingKey {
        case requestID = "request_id"
        case status
        case createdAt = "created_at"
        case remainingTime = "remaining_time"
        case jobTitle = "job_title"
        case jobber
        case serviceCount = "service_count"
        case requestLifeTime = "request_life_time"
        case userTimePaying = "user_time_paying"
        case tag
        case totalPay = "total_pay"
    }
}


// MARK: - Jobber
struct UserJobberDetail: Codable {
    let id, identifier: String?
    let avatar: String?
    let name, family: String?
}
