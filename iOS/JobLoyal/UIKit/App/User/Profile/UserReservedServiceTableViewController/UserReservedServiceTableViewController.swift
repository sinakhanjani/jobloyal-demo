//
//  UserReservedServiceTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit
import RestfulAPI

class UserReservedServiceTableViewController: UserTableViewController {
    
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case hour(ReservedServiceModel)
        case numeric(ReservedServiceModel)
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,Item>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    var items:[ReservedServiceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Reserved Services".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        perform()
        fetchReservedList()
    }
    
    private func fetchReservedList() {
        let limit = 40
        let page = items.count/limit
        guard items.count%limit == 0 else { return }
        
        struct SendReservedList: Codable { let limit: Int ; let page: Int }
        let network = RestfulAPI<SendReservedList,Generic<RCReservedServicesModel>>.init(path: "/user/service/reserved_services")
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
        
        tableView.backgroundView = items.isEmpty ? EmptyReservedInboxView():nil
        
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
                self.fetchReservedList()
            }
            
            switch item {
            case .hour(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserReservedServiceHourTableViewCell.identifier) as! UserReservedServiceHourTableViewCell
                cell.updateUI(serviceName: item.title ?? "", price: Double(item.price ?? "0.0")!, time: item.totalTime ?? "", jobberName: item.jobberName ?? "", reservedDate: item.reservedAt?.to(date: "dd/MM/YYYY") ?? "")
                
                return cell
            case .numeric(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserReservedServiceNumericTableViewCell.identifier) as! UserReservedServiceNumericTableViewCell
                cell.updateUI(serviceName: item.title ?? "", price: Double(item.price ?? "0.0")!, unitName: item.unit ?? "", unitValue: item.count ?? "0", jobberName: item.jobberName ?? "", reservedDate: item.reservedAt?.to(date: "dd/MM/YYYY") ?? "")
                
                return cell
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension UserReservedServiceTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
