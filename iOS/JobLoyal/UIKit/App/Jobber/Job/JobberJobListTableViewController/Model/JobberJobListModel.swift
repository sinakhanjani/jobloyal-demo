//
//  JobberJobListModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct JobberJobListsModel: Codable, Hashable {
    let items: [JobberJobListModel]?
}

// MARK: - Item
struct JobberJobListModel: Codable, Hashable {
    let id, title, categoryID, createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case categoryID = "category_id"
        case createdAt, updatedAt
    }
}

struct SendJobberJobListModel: Codable {
    let category_id: String
}
