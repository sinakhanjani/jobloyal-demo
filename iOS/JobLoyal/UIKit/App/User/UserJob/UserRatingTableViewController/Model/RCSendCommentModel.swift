//
//  RCSendCommentModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/5/1400 AP.
//

import Foundation


// MARK: - DataClass
struct RCSendCommentModel: Codable {
    let id: Int?
    let jobberID, jobID: String?
    let star1, star2, star3, star4, star5: Double?
    let rate, work: Double?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case jobberID = "jobber_id"
        case jobID = "job_id"
        case star1, star2, star3, star4, star5, rate, work, createdAt, updatedAt
    }
}
