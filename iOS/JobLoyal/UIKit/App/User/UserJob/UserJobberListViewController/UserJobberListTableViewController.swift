//
//  UserJobberListTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit
import CoreLocation
import RestfulAPI

class UserJobberListTableViewController: UserTableViewController {
    
    enum Section: Hashable {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,RCJobberListModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, RCJobberListModel>()
    
    var items:[RCJobberListModel] = []
    
    var userJobCategoryItem: UserJobCategoryItem?
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Jobber".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        fetch()
        perform()
    }
    
    func fetch() {
        if case .job(let job) = userJobCategoryItem {
            // request
            if let id = job.id {
                fetchJobberList(jobID: id, serviceID: nil)
            }
        }
        if case .service(let service) = userJobCategoryItem {
            // request
            fetchJobberList(jobID: service.jobID, serviceID: service.serviceID)
        }
    }
    
    private func fetchJobberList(jobID: String, serviceID: String?) {
        guard let coordinate = self.coordinate else { return }
        let limit = 40
        let page = items.count/limit
        guard items.count%limit == 0 else { return }
        let path = serviceID == nil ? "find_by_job":"find_by_service"

        let body = SendJobberListModel(latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude), page: page, limit: limit, jobID: jobID, serviceID: serviceID)
        let network = RestfulAPI<SendJobberListModel,Generic<RCJobbersListModel>>.init(path: "/user/jobber/\(path)")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }
            
            self.items = (self.items + (response.data?.items ?? [])).uniqued()
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
        }
    }

    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,RCJobberListModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,RCJobberListModel>()
        
        tableView.backgroundView = items.isEmpty ? EmptyJobberListInboxView():nil
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource<Section,RCJobberListModel>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberListTableViewCell.identifier) as! UserJobberListTableViewCell
            let isSuggested = ((item.distance ?? 0.0)/1000 < 10) || (indexPath.item == 0)
            
            cell.updateUI(shortFullyName: item.avatar ?? "-", jobberID: item.identifier ?? "-", distance: item.distance ?? 0.0, rate: item.rate ?? "0.0", workedNumber: Int((item.workCount ?? 0)), isSuggested: isSuggested)
            
            if indexPath.item == (self.items.count - 1) { self.fetch() }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension UserJobberListTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserJobberJobTableViewController.instantiateVC(.user)
        vc.jobberListModel = self.items[indexPath.item]
        vc.coordinate = coordinate
        
        show(vc, sender: nil)
    }
}
