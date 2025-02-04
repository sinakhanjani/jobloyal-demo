//
//  JobberUnitTypeTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit

protocol JobberUnitTypeTableViewControllerDelegate: AnyObject {
    func selected(_ unitType: UnitTypeModel)
}

class JobberUnitTypeTableViewController: JobberTableViewController {
    
    enum Section {
        case main
    }
    
    private var tableViewViewDataSource: UITableViewDiffableDataSource<Section, UnitTypeModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, UnitTypeModel>()
    private let unitTypes: [UnitTypeModel] = [.numeric,.hour]
    
    weak open var delegate: JobberUnitTypeTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, UnitTypeModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,UnitTypeModel>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(unitTypes, toSection: Section.main)

        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()

        dataSource()
        
        tableViewViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func dataSource() {
        tableViewViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
            
            cell.textLabel?.text = item.value
            
            return cell
        })
    }
}

extension JobberUnitTypeTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PASSING DATA
        let unitType = unitTypes[indexPath.item]
        
        delegate?.selected(unitType)
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
