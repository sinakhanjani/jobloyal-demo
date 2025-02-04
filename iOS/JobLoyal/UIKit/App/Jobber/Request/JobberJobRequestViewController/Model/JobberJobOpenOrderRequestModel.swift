//
//  JobberJobOpenOrderRequestModel.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/30/1400 AP.
//

import Foundation

enum JobberAccpetRequestItem: Hashable {
    case base(item: JobberAcceptJobStatusModel)
    case detail(item: JobberAcceptJobStatusModel)
    case service(item: JobberRequestServiceModel)
    case arrivalTime
    case map(lat: Double, long: Double, address: String)
}

// MARK: - DataClass
struct JobberAcceptJobStatusModel: Codable, Hashable {
    let longitude, latitude: Double?
    let total: String
    let remainingTimeToPay: Int
    let distance: Double?
    let address: String?
    let jobID: String
    let status: String?
    let arrivalTime: String?
    let timeBase: Bool
    let user: User?
    let services: [JobberRequestServiceModel]
    let userTimePaying: Int
    let updatedAt: String?
    let totalTimeInterval: Int?
    
    enum CodingKeys: String, CodingKey {
        case longitude, latitude, total
        case remainingTimeToPay = "remaining_time_to_pay"
        case distance, address
        case jobID = "job_id"
        case status
        case arrivalTime = "arrival_time"
        case timeBase = "time_base"
        case user, services
        case userTimePaying = "user_time_paying"
        case updatedAt = "updated_at"
        case totalTimeInterval = "total_time_interval"
    }
}

// MARK: - User
struct User: Codable, Hashable {
    let name, phone: String?
}

/*
{
    "success": true,
    "data": {
        "longitude": 51.4329500000001,
        "latitude": 33.997401,
        "total": "4.50",
        "distance": 96848.4277054535,
        "address": "شهید منصوری",
        "job_id": "2718d7d1-63d6-46d8-9376-edb57f683594",
        "status": "accepted",
        "arrival_time": "30",
        "time_base": true,
        "user": {
            "name": "sina khanjani",
            "phone": "+41772024547"
        },
        "services": [
            {
                "title": "Pose de barre de douche",
                "count": 0,
                "price": 4.5,
                "total_price": 4.5,
                "accepted": true,
                "unit": null,
                "request_id": "9baadf3b-b48e-4dc8-bcb3-f48a15bdf40e"
            }
        ]
    },
    "message": "success",
    "code": 0
}
*/
