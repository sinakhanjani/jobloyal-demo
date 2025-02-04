//
//  AddJobberJobModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct RCAddJobberJobModel: Codable {
    let jobberID, jobID: String
    let enabled: Bool

    enum CodingKeys: String, CodingKey {
        case jobberID = "jobber_id"
        case jobID = "job_id"
        case enabled
    }
}
