//
//  ProfileMenuModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import Foundation

enum JobberProfileMenuModel: Hashable {
    case main(JobberInfoMenuModel)
    case creditOrAuth(item: Authorize)
    case menu(item: JobberMenuModel)
}

enum Authorize: Hashable {
    case noAuthorize
    case nonAcceptedPhoto
    case pendingAuthorize
    case completeProfile
    case doneAuthorize(Double)
}

