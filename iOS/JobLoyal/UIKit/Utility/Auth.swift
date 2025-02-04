//
//  Auth.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import Foundation
import RestfulAPI

struct Auth {
    // singletone shared class
    static var shared = Auth()
    // auth variable for user and jobber
    var user: Authentication = .user
    var jobber: Authentication = .jobber
    var none: Authentication = .none
}
