//
//  UserJobCatehoryTableViewDiffableDataSource.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit

class UserJobCategoryTableViewDiffableDataSource: UITableViewDiffableDataSource<UserJobCategoryViewController.Section,UserJobCategoryItem> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .category(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
                cell.textLabel?.text = item.title
                
                return cell
            case .job(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
                cell.textLabel?.text = item.title

                return cell
            case .service(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: userJobCategoryServiceTableViewCell.identifier) as! userJobCategoryServiceTableViewCell
                cell.updateUI(categoryTitle: item.categoryTitle, jobTitle: item.jobTitle, serviceTitle: item.serviceTitle)

                return cell
            }
        }
    }
}
