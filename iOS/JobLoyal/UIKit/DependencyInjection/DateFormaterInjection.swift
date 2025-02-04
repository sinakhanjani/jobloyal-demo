//
//  DateInjection.swift
//  Nerkh
//
//  Created by Sina khanjani on 1/19/1399 AP.
//  Copyright © 1399 Sina Khanjani. All rights reserved.
//

import Foundation

protocol DateFormaterInjection {
    var dateFormmater: DateFormatter { get }
}

extension DateFormaterInjection {
    var dateFormmater: DateFormatter {
        get {
            let dateFormmater = DateFormatter()
            dateFormmater.calendar = Calendar(identifier: .gregorian)
            dateFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            return dateFormmater
        }
    }
    
    func changedDateFormat(_ dateFormat: String) {
        dateFormmater.dateFormat = dateFormat
    }
}
