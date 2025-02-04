//
//  UserEditProfileModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/6/1400 AP.
//

import Foundation

// MARK: - RCSendCommentModel
struct SendUserEditProfileModel: Codable {
    let name, family, gender, email: String?
    let address, birthday: String?
}
