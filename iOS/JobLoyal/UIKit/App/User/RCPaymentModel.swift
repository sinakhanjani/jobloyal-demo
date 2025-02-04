//
//  RCPaymentModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 5/2/1400 AP.
//

import Foundation

struct RCPaymentModel: Codable {
    let id, client_secret, ephemeral_key, customer: String?
    let paid: Bool?
}
