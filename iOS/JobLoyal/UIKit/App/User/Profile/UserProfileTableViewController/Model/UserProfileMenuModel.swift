//
//  UserProfileMenuModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import Foundation

enum UserProfileMenuModel: Hashable {
    case main(UserInfoMenuModel)
    case wallet(Double)
    case menu(item: UserMenuModel)
}
