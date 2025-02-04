//
//  JobberAcceptRequetItem.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import Foundation
import CoreLocation

enum JobberOrderItem: Hashable {
    case base(item: JobberRequestModel)
    case detail(item: JobberRequestModel)
    case service(item: JobberRequestServiceModel)
    case arrivalTime
    case map(lat: Double, long: Double, address: String)
}
