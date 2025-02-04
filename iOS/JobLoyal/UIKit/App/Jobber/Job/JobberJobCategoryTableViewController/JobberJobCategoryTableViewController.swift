//
//  JobberJobCategoryTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit
import RestfulAPI

class JobberJobCategoryTableViewController: JobberTableViewController {
    
    enum Section {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section, JobberCategoryModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberCategoryModel>()
    
    private var items: [JobberCategoryModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        perform()
        fetch()
    }
    
    private func fetch() {
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberCategoriesModel>>.init(path: "/jobber/categories")
            .with(auth: .jobber)
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self, let data = response.data else { return }
            
            self.items = data.items
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, JobberCategoryModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberCategoryModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()
        
        tableViewDataSource = UITableViewDiffableDataSource.init(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            cell.textLabel?.text = item.title.firstUppercased
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension JobberJobCategoryTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        if let children = item.children {
            let vc = JobberJobCategoryTableViewController.instantiateVC(.jobber)
            vc.items = children
            vc.title = item.title
            
            show(vc, sender: nil)
        } else {
            let vc = JobberJobListTableViewController.instantiateVC(.jobber)
            vc.catID = item.id
            vc.title = item.title
            
            show(vc, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
