//
//  AddJobberServiceModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - SendAddJobberServiceModel
struct SendAddJobberServiceModel: Codable {
    let jobID, serviceID: String
    let unitID: String?
    let price: Double

    enum CodingKeys: String, CodingKey {
        case jobID = "job_id"
        case serviceID = "service_id"
        case unitID = "unit_id"
        case price
    }
}
