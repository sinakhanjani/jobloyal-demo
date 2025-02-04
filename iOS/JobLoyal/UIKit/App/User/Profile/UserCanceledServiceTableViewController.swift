//
//  UserCanceledServiceTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit
import RestfulAPI

class UserCanceledServiceTableViewController: UserTableViewController {
    
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case hour(CancelServiceModel)
        case numeric(CancelServiceModel)
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,Item>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    var items:[CancelServiceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Canceled Services".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        perform()
        fetchCancelList()
    }
    
    private func fetchCancelList() {
        let limit = 40
        let page = items.count/limit
        
        guard items.count%limit == 0 else { return }
        
        struct SendReservedList: Codable { let limit: Int ; let page: Int }
        
        let network = RestfulAPI<SendReservedList,Generic<RCCancelServicesModel>>.init(path: "/user/service/canceled_services")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: SendReservedList(limit: limit, page: page))
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }
            self.items = (self.items + (response.data?.items ?? [])).uniqued()
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
        }
    }

    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.main])
        
        tableView.backgroundView = items.isEmpty ? EmptyCanceledInboxView():nil

        let reservedHourServices = items.filter { $0.unit == nil }.map { return Item.hour($0) }
        let reservedNumericServices = items.filter { $0.unit != nil }.map { return Item.numeric($0) }

        snapshot.appendItems(reservedHourServices)
        snapshot.appendItems(reservedNumericServices)

        return snapshot
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource<Section,Item>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            if indexPath.item == (self.items.count - 1) {
                self.fetchCancelList()
            }
            
            switch item {
            case .hour(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCanceledServiceHourTableViewCell.identifier) as! UserCanceledServiceHourTableViewCell
                let canceledBy = (item.canceledBy == "jobber") ? "Jobber".localized():"You".localized()
                cell.updateUI(serviceName: item.title ?? "", price: Double(item.price ?? "0.0")!, reservedDate: item.reservedAt?.to(date: "dd/MM/YYYY") ?? "", canceledBy: canceledBy)
                
                return cell
            case .numeric(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCanceledServiceNumericTableViewCell.identifier) as! UserCanceledServiceNumericTableViewCell
                let canceledBy = (item.canceledBy == "jobber") ? "Jobber".localized():"You".localized()

                cell.updateUI(serviceName: item.title ?? "", price: Double(item.price ?? "0.0")!, unitName: item.unit ?? "", unitValue: item.count ?? "0", reservedDate: item.reservedAt?.to(date: "dd/MM/YYYY") ?? "", canceledBy: canceledBy)
                
                return cell
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension UserCanceledServiceTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
