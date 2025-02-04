//
//  UnitListModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import Foundation

// MARK: - UnitsModel
struct UnitsModel: Codable, Hashable {
    let items: [UnitModel]
}

// MARK: - UnitModel
struct UnitModel: Codable, Hashable {
    let id: String?
    var title: String?
    
    static func == (lhs: UnitModel, rhs: UnitModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
