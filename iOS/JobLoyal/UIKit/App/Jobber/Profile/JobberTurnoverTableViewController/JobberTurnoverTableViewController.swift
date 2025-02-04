//
//  JobberTurnoverTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit
import RestfulAPI

class JobberTurnoverTableViewController: JobberTableViewController {
    
    enum Section: Hashable {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,TurnoverRowModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, TurnoverRowModel>()
    
    var items: [Turnover] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Turnover".localized()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        perform()
        fetch()
    }
    
    func fetch() {
        let network = RestfulAPI<EMPTYMODEL,Generic<TurnoversModel>>.init(path: "/jobber/turnover")
            .with(auth: .jobber)

        handleRequestByUI(network) { [weak self] response in
            guard let self = self else { return }
            
            self.items = response.data?.items ?? []
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
        }
    }

    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,TurnoverRowModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,TurnoverRowModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.header], toSection: .main)
        
        let rowModels = items.map { TurnoverRowModel.item($0) }

        tableView.backgroundView = rowModels.isEmpty ? EmptyTurnoverInboxView():nil
        snapshot.appendItems(rowModels, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()
        tableViewDataSource = UITableViewDiffableDataSource<Section,TurnoverRowModel>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: JobberTurnoverTableViewCell.identifier) as! JobberTurnoverTableViewCell
            
            switch item {
            case .header:
                cell.backgroundColor = .heavyBlue
                cell.changeLabelColor(.white)
            case .item(let item):
                cell.updateUI(title: "Deposit".localized(), date: item.createdAt?.to(date: "YYYY/MM/dd") ?? "", price: item.amount ?? "", status: item.status ?? "")
                break
            }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot)
    }
}

extension JobberTurnoverTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}


/*
 {
     "success": true,
     "data": {
         "items": [
             {
                 "id": "2534dbe1-fd7d-4e83-ac7a-ff5cb0e012db",
                 "jobber_id": "2534dbe1-fd7d-4e83-ac7a-ff5cb0e012da",
                 "amount": "1.00",
                 "status": "success",
                 "ref_code": "msg2021072000440411860f61c541ceb0",
                 "createdAt": "2021-07-19T05:01:55.569Z",
                 "updatedAt": "2021-07-21T08:40:02.669Z"
             }
         ]
     },
     "message": "success",
     "code": 0
 }
 */
