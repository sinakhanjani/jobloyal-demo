//
//  JobberServiceListTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit
import RestfulAPI

class JobberServiceListTableViewController: JobberTableViewController {
    
    enum Section {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,ServiceListModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, ServiceListModel>()
    
    private let searchController = UISearchController()
    private var items: [ServiceListModel] = []
    
    public var jobID: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.searchController.searchBar.searchTextField.becomeFirstResponder()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func sear$etch(searchTitle: String, completion: @escaping (_ items: [ServiceListModel]) -> Void) {
        guard let jobID = self.jobID else { return }
        struct Search: Codable {
            let jobId: String
            let s: String
        }
        
        let network = RestfulAPI<Search,Generic<ServicesListModel>>.init(path: "jobber/service/search")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: Search(jobId: jobID, s: searchTitle))
        
        handleRequestByUI(network, animated: false) { (response) in
            completion(response.data?.items ?? [])
        }
    }
    
    private func fetchServiceList(jobID: String?) {
        guard let jobID = jobID else { return }
        
        struct SendServiceListModel: Codable { let job_id: String }
        
        let network = RestfulAPI<SendServiceListModel,Generic<ServicesListModel>>.init(path: "/jobber/service/get")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendServiceListModel(job_id: jobID))
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            
            self.items = response.data?.items ?? []
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
        }
    }
    
    private func configurationSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.searchTextField.placeholder = "X831-31-nbv1".localized()
        searchController.searchBar.searchTextField.font = UIFont.avenirNextMedium(size: 17)
        searchController.searchBar.setImage(UIImage(), for: .search, state: .normal)
    }
    
    private func updateUI() {
        configurationSearchBar()
        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, ServiceListModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,ServiceListModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource.init(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            
            cell.textLabel?.text = item.title
            cell.imageView?.image = (item.id == nil) ? UIImage(systemName: "plus"):nil
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func handleFetchedItems(_ items: [ServiceListModel], searchTitle: String) {
        let currentSnapshotItems = snapshot.itemIdentifiers
        var allItems = currentSnapshotItems + items
        let sameItems = allItems.filter { (item) -> Bool in
            let lowerCaseItemWithNoSpaced = item.title.lowercased().replacingOccurrences(of: " ", with: "")
            let lowerCaseSearchTitleWithNoSpaced = searchTitle.lowercased().replacingOccurrences(of: " ", with: "")

            return (lowerCaseItemWithNoSpaced == lowerCaseSearchTitleWithNoSpaced)
        }

        if sameItems.count != 1 {
            allItems.append(ServiceListModel.init(id: nil, title: searchTitle, jobID: "", defaultUnitID: nil, creatorUserID: nil, createdAt: nil, updatedAt: nil, unit: nil))
        }
        
        var updatedSnapshot = NSDiffableDataSourceSnapshot<Section, ServiceListModel>()
        
        updatedSnapshot.appendSections([.main])
        updatedSnapshot.appendItems(allItems, toSection: .main)
                
        snapshot = updatedSnapshot
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func fetchResult(searchTitle: String) {
        //1. send request to server...
        sear$etch(searchTitle: searchTitle) { [weak self] (items) in
            guard let self = self else { return }
            //2. when response comming, insert the response to this method
            self.handleFetchedItems(items, searchTitle: searchTitle)
        }
    }

    @objc private func fetchMatchingItems() {
        guard searchController.isActive else { return }
        // search word if not empty
        let searchTerm = searchController.searchBar.text ?? ""
        // clear data sources
        snapshot.deleteAllItems()
        tableViewDataSource.apply(snapshot)
        // fetch from server and reload snapshot if searchTerm is not empty
        if !searchTerm.isEmpty {
            searchTerm.count > 2 ?
                fetchResult(searchTitle: searchTerm)
                :
                handleFetchedItems([], searchTitle: searchTerm)
        }
    }
}

extension JobberServiceListTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 1)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension JobberServiceListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = snapshot.itemIdentifiers
        let item = items[indexPath.item]
        let vc = JobberServiceTableViewController.instantiateVC(.jobber)

        vc.title = item.title
        vc.jobID = jobID ; vc.serviceListModel = item
        
        show(vc, sender: nil)
    }
}
