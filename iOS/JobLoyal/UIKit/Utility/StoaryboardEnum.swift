//
//  StoaryboardEnum.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/13/1399 AP.
//

import Foundation

public enum Storyboard: String, CaseIterable, Codable {
    case main = "Main"
    case user = "User"
    case jobber = "Jobber"

    var name: String {
        rawValue
    }
}
