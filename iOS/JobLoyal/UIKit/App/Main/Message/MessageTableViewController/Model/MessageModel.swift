//
//  MessageModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/29/1400 AP.
//

import Foundation

// MARK: - DataClass
struct MessagesModel: Codable, Hashable {
    let items: [MessageModel]
}

// MARK: - Item
struct MessageModel: Codable, Hashable {
    let id, userID, subject, itemDescription: String?
    let createdAt, updatedAt: String?
    let reply: MessageReplyModel?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case subject
        case itemDescription = "description"
        case createdAt, updatedAt, reply
    }
}

// MARK: - RCSendCommentModel
struct MessageReplyModel: Codable, Hashable {
    let id, messageID, answer, createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case messageID = "message_id"
        case answer, createdAt, updatedAt
    }
}


