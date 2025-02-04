//
//  JobberJobServiceSection.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit

enum JoberJobServiceItem: Hashable {
    case rate(from: Int, averageRate: Double)
    case detail(totalIncome: Double, doneJob: Int, allRequests: Int)
    case add
    case service(name: String, unitName: String?, price: Double, id: String)
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case let .rate(from, averageRate):
            let cell = tableView.dequeueReusableCell(withIdentifier: RateTableViewCell.identifier, for: indexPath) as! RateTableViewCell
            cell.updateUI(from: from, averageRate: averageRate)

            return cell
        case  let .detail(totalIncome, doneJob, allRequests):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as! DetailTableViewCell
            cell.updateUI(totalIncome: totalIncome, doneJob: doneJob, allRequests: allRequests)
            
            return cell
        case .add:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddTableViewCell.identifier, for: indexPath) as! AddTableViewCell

            return cell
        case let .service(name, unitName, price, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ServiceTableViewCell.identifier, for: indexPath) as! ServiceTableViewCell
            cell.updateUI(name: name, unitName: unitName, price: price)

            return cell
        }
    }
}
