//
//  CommentModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/30/1400 AP.
//

import Foundation

// MARK: - DataClass
struct RCCommentsModel: Codable {
    let items: [CommentModel]?
}

struct CommentModel: Codable, Hashable {
    let id: Int
    let service_title: String?
    let comment: String?
    let rate: String?
}

struct SendJobberCommentModel: Codable {
    let job_id: String
    let page: Int
    let limit: Int
}

struct SendUserCommentModel: Codable {
    let jobber_id: String
    let job_id: String
    let page: Int
    let limit: Int
}
