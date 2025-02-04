//
//  Generic.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/28/1400 AP.
//

import Foundation

struct Generic<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String
    let code: Int?
}

struct Empty: Codable, Hashable {
    
}
