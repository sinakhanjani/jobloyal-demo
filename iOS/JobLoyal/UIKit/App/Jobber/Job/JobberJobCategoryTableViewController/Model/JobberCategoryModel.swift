//
//  JobberCategoryModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct JobberCategoriesModel: Codable, Hashable {
    let items: [JobberCategoryModel]
}
// MARK: - JobberCategoryModel
struct JobberCategoryModel: Codable, Hashable {
    let id, title, createdAt, updatedAt: String
    let children: [JobberCategoryModel]?
}
