//
//  UserProfileModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/5/1400 AP.
//

import Foundation

// MARK: - UserProfileModel
struct UserProfileModel: Codable, Hashable {
    let id, name, family: String?
    let gender: Bool?
    let email, address, phoneNumber, birthday: String?
    let region, createdAt, updatedAt: String?
    let credit: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, family, gender, email, address
        case phoneNumber = "phone_number"
        case birthday, region, createdAt, updatedAt, credit
    }
}

struct UserInfoMenuModel: Codable, Hashable {
    let name, family, phoneNumber: String?
    
    init(userProfileModel: UserProfileModel) {
        name = userProfileModel.name
        family = userProfileModel.family
        phoneNumber = userProfileModel.phoneNumber
    }
}
