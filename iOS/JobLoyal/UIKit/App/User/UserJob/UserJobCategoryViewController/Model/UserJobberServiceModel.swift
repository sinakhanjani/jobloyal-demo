//
//  UserJobberServiceModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/2/1400 AP.
//

import Foundation

// MARK: - UserJobberServicesModel
struct UserJobberServicesModel: Codable, Hashable {
    let items: [UserJobberServiceModel]
}

// MARK: - UserJobberServiceModel
struct UserJobberServiceModel: Codable, Hashable {
    let serviceID, jobID, jobTitle, serviceTitle: String
    let categoryTitle: String

    enum CodingKeys: String, CodingKey {
        case serviceID = "service_id"
        case jobID = "job_id"
        case jobTitle = "job_title"
        case serviceTitle = "service_title"
        case categoryTitle = "category_title"
    }
}
