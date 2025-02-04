//
//  ServiceListModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import Foundation

// MARK: - DataClass
struct ServicesListModel: Codable, Hashable {
    let items: [ServiceListModel]
}

// MARK: - Item
struct ServiceListModel: Codable, Hashable {
    let id: String?
    let title: String
    let jobID: String?
    let defaultUnitID, creatorUserID: String?
    let createdAt, updatedAt: String?
    let unit: UnitModel?

    enum CodingKeys: String, CodingKey {
        case id, title
        case defaultUnitID = "default_unit_id"
        case creatorUserID = "creator_user_id"
        case jobID = "job_id"
        case createdAt, updatedAt, unit
    }
    
    static func == (lhs: ServiceListModel, rhs: ServiceListModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
