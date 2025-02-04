//
//  JobberTurnoverTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/12/1400 AP.
//

import UIKit

class UserTurnoverTableViewController: UserTableViewController {
    
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
            case .item(let turnover):
//                cell.updateUI(title: <#T##String#>, date: <#T##String#>, price: <#T##Double#>)
                
                break
            }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension UserTurnoverTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
