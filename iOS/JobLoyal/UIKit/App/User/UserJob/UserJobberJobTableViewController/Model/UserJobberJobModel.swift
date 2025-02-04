//
//  JobberJobModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/3/1400 AP.
//

import Foundation

// MARK: - Empty
struct SendJobberJobModel: Codable {
    let jobberID, jobID: String
    let latitude, longitude: Double

    enum CodingKeys: String, CodingKey {
        case jobberID = "jobber_id"
        case jobID = "job_id"
        case latitude, longitude
    }
}

// MARK: - RCJobberJobModel
struct RCJobberJobModel: Codable, Hashable {
    let identifier, aboutMe, avatar: String?
    let rate: String?
    let workCount: Int?
    let totalComments: Int?
    let status: String?
    let distance: Double?
    let services: [ServiceJobModel]?
    let comments: [CommentModel]?

    enum CodingKeys: String, CodingKey {
        case identifier
        case aboutMe = "about_me"
        case avatar, rate
        case workCount = "work_count"
        case totalComments = "total_comments"
        case status, distance, services, comments
    }
}

// MARK: - Service
struct ServiceJobModel: Codable, Hashable {
    let id, title: String?
    let price: Double?
    let unit: String?
    let commission: Double?
    var totalPrice: Double? = 0.0
    var count: Int? = 0
}
