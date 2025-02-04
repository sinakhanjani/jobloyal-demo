//
//  CommentTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit
import RestfulAPI

class CommentTableViewController: InterfaceTableViewController {
    
    enum Section {
        case main
    }
    
    private var tableViewViewDataSource: UITableViewDiffableDataSource<Section, CommentModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, CommentModel>()
    private var items: [CommentModel] = []
    
    weak var delegate: JobberUnitTypeTableViewControllerDelegate?
    var auth: Authentication = .jobber
    var jobID: String?
    var jobberID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func checkAuth() {
        auth = Authentication.user.isLogin ? .user:.jobber
    }
    
    private func fetchJobberComments(jobID: String?, animated: Bool) {
        checkAuth()
        guard auth == .jobber else { return }
        
        let limit = 40
        let page = items.count/limit
        
        guard items.count%limit == 0 else { return }
        guard let jobID = jobID else { return }
        
        let path = auth == .jobber ? "jobber":"user"
        let network = RestfulAPI<SendJobberCommentModel,Generic<RCCommentsModel>>.init(path: "/\(path)/comments")
            .with(auth: auth)
            .with(method: .POST)
            .with(body: SendJobberCommentModel(job_id: jobID, page: page, limit: limit))
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }

            self.items = (self.items + (response.data?.items ?? [])).uniqued()
            self.snapshot = self.createSnapshot()
            self.tableViewViewDataSource.apply(self.snapshot, animatingDifferences: animated)
        }
    }
    
    private func fetchUserComments(jobID: String?, jobberID: String?, animated: Bool) {
        checkAuth()
        guard auth == .user else { return }
        
        let limit = 40
        let page = items.count/limit
        
        guard items.count%limit == 0 else { return }
        guard let jobID = jobID, let jobberID = jobberID else { return }
        
        let path = auth == .jobber ? "jobber":"user"
        let network = RestfulAPI<SendUserCommentModel,Generic<RCCommentsModel>>.init(path: "/\(path)/comments")
            .with(auth: auth)
            .with(method: .POST)
            .with(body: SendUserCommentModel(jobber_id: jobberID, job_id: jobID, page: page, limit: limit))
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }
            
            self.items = (self.items + (response.data?.items ?? [])).uniqued()
            self.snapshot = self.createSnapshot()
            self.tableViewViewDataSource.apply(self.snapshot, animatingDifferences: animated)
        }
    }
    
    private func updateUI() {
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        perform()
        fetchJobberComments(jobID: jobID, animated: true)
        fetchUserComments(jobID: jobID, jobberID: jobberID, animated: true)
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, CommentModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,CommentModel>()
        
        tableView.backgroundView = items.isEmpty ? EmptyCommentsInboxView():nil
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: Section.main)

        return snapshot
    }
    
    private func perform() {        
        registerTableViewCell(tableView: tableView, cell: CommentTableViewCell.self)
        dataSource()
        
        tableViewViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func dataSource() {
        tableViewViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
            cell.updateUI(subject: item.service_title ?? "", description: item.comment ?? "", rating: Double(item.rate ?? "0.0")!)
            if indexPath.item == (self.items.count - 1) {
                self.fetchJobberComments(jobID: self.jobID, animated: false)
                self.fetchUserComments(jobID: self.jobID, jobberID: self.jobberID, animated: false)
            }
            
            return cell
        })
    }
}

extension CommentTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
