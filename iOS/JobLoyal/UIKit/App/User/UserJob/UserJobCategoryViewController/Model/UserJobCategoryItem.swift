//
//  UserJobCategoryItem.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import Foundation

enum UserJobCategoryItem: Hashable {
    case category(JobberCategoryModel)
    case job(JobberJobListModel)
    case service(UserJobberServiceModel)
}
