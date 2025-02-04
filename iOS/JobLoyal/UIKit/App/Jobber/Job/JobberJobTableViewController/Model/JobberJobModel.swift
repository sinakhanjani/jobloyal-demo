//
//  JobberJobModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct JobberJobsModel: Codable, Hashable {
    let items: [JobberJobModel]?
}

// MARK: - Item
struct JobberJobModel: Codable, Hashable {
    let jobID: String
    let enabled: Bool?
    let title, serviceConut: String?
    let status, statusCreatedTime: String?
    
    init(jobID: String, enabled: Bool?, title: String?, serviceConut: String?, status: String?, statusCreatedTime: String?) {
        self.jobID = jobID
        self.enabled = enabled
        self.title = title
        self.serviceConut = serviceConut
        self.status = status
        self.statusCreatedTime = statusCreatedTime
    }
    
    init(jobID: String) {
        self.jobID = jobID
        self.enabled = nil
        self.title = nil
        self.serviceConut = nil
        self.status = nil
        self.statusCreatedTime = nil
    }

    enum CodingKeys: String, CodingKey {
        case jobID = "job_id"
        case enabled, title
        case serviceConut = "service_conut"
        case status
        case statusCreatedTime = "status_created_time"
    }
}
