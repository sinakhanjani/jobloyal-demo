//
//  JobberJobReportTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit
import RestfulAPI

class JobberJobReportTableViewController: JobberTableViewController {

    enum Section: Hashable {
        case main
    }
    
    var items: [ReportJobModel] = []
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,ReportJobModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, ReportJobModel>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetch(animated: false, refresh: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        perform()
    }
    
    private func fetch(animated: Bool, refresh: Bool = false) {
        let limit = 40
        let page = items.count/limit
        if !refresh {
            guard items.count%limit == 0 else { return }
        }
        
        let network = RestfulAPI<SendReportModel,Generic<ReportsJobModel>>.init(path: "/jobber/report")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendReportModel(page: page, limit: limit))
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            
            self.items = (self.items + (response.data?.items ?? [])).uniqued()
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot, animatingDifferences: animated)
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,ReportJobModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,ReportJobModel>()

        tableView.backgroundView = items.isEmpty ? EmptyJobReportInboxView():nil
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource<Section,ReportJobModel>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: JobberJobReportTableViewCell.identifier) as! JobberJobReportTableViewCell
            
            cell.updateUI(address: item.address ?? "", date: item.createdAt?.to(date: "YYYY-MM-dd HH:mm") ?? "-", jobTitle: item.jobTitle ?? "", tag: item.tag ?? "")
            
            if indexPath.item == (self.items.count - 1) {
                self.fetch(animated: false)
            }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension JobberJobReportTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = JobberJobServiceReportTableViewController.instantiateVC(.jobber)
        let item = items[indexPath.item]
        
        vc.reportID = item.id
        vc.tag = item.tag
        vc.title = item.jobTitle
        
        show(vc, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
