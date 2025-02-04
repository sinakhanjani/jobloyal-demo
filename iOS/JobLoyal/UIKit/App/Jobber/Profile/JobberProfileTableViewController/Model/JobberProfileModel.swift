//
//  ProfileModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/31/1400 AP.
//

import Foundation

// MARK: - DataClass
struct JobberProfileModel: Codable, Hashable {
    let id, name, family: String?
    let gender: Bool?
    let email: String?
    let avatar: String?
    let zipCode: Int?
    let address, identifier: String?
    let authorized: Bool?
    let phoneNumber, birthday, region, aboutUs: String?
    let createdAt, updatedAt: String?
    let credit: Double?
    let statics: Statics?
    let authority: Authority?

    enum CodingKeys: String, CodingKey {
        case id, name, family, gender, email, avatar
        case zipCode = "zip_code"
        case address, identifier, authorized
        case phoneNumber = "phone_number"
        case birthday, region
        case aboutUs = "about_us"
        case createdAt, updatedAt, credit, statics, authority
    }
}

// MARK: - Authority
struct Authority: Codable, Hashable {
    let status: String?
    let code: Int?
    let message, doc: String?
}

// MARK: - Statics
struct Statics: Codable, Hashable {
    let id: Int?
    let jobberID: String?
    let smsEnabled, notificationEnabled: Bool?
    let ponyPeriod: Int?
    let cardNumber, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case jobberID = "jobber_id"
        case smsEnabled = "sms_enabled"
        case notificationEnabled = "notification_enabled"
        case ponyPeriod = "pony_period"
        case cardNumber = "card_number"
        case createdAt, updatedAt
    }
}


struct JobberInfoMenuModel: Codable, Hashable {
    let id, name, family: String?
    let phoneNumber: String?
    let avatar: String?
    let identifier: String?
    
    init(jobberProfileModel: JobberProfileModel) {
        id = jobberProfileModel.id
        phoneNumber = jobberProfileModel.phoneNumber
        avatar = jobberProfileModel.avatar
        name = jobberProfileModel.name
        family = jobberProfileModel.family
        identifier = jobberProfileModel.identifier
    }
}
