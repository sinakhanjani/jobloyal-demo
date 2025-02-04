//
//  AddNewJobTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit
import RestfulAPI

class JobberJobListTableViewController: JobberTableViewController {
    
    enum Section {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,JobberJobListModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberJobListModel>()
    
    private var items: [JobberJobListModel] = []
    
    public var catID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        perform()
        fetch(catID: catID)
    }
    
    private func fetch(catID: String?) {
        guard let catID = catID else { return }
        let network = RestfulAPI<SendJobberJobListModel,Generic<JobberJobListsModel>>.init(path: "/jobber/job/get")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendJobberJobListModel(category_id: catID))
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self, let data = response.data else { return }
            
            self.items = data.items ?? []
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, JobberJobListModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberJobListModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {        
        tableViewDataSource = UITableViewDiffableDataSource.init(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            cell.textLabel?.text = item.title?.firstUppercased
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension JobberJobListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = JobberJobServiceTableViewController.instantiateVC(.jobber)
        let item = items[indexPath.item]
        vc.title = item.title
        vc.jobID = item.id
        
        show(vc, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
