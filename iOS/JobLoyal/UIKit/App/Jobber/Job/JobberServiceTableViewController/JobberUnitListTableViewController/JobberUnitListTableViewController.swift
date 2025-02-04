//
//  JobberUnitListTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit
import RestfulAPI

protocol JobberUnitListTableViewControllerDelegate: AnyObject {
    func selectedUnit(_ unitModel: UnitModel)
}

class JobberUnitListTableViewController: JobberTableViewController {
    
    enum Section {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,UnitModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, UnitModel>()
    
    private let searchController = UISearchController()
    private var items: [UnitModel] = []
    private let searchPlaceholder = "Search or add a Unit".localized()

    weak open var delegate: JobberUnitListTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func configurationSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesSearchBarWhenScrolling = true

        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.searchTextField.placeholder = searchPlaceholder
    }
    
    private func updateUI() {
        let rightBarButton = UIBarButtonItem(image: nil, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(rightBarButtonTapped))
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.avenirNextBold(size: 17)], for: [.normal])
        rightBarButton.title = "Add Unit".localized()
        navigationItem.rightBarButtonItem = rightBarButton

        configurationSearchBar()
        perform()
        fetchAllUnits()
    }
    
    private func fetchAllUnits() {
        fetch { [weak self] (items) in
            guard let self = self else { return }
            self.items = items
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    private func fetch(completion: @escaping (_ items: [UnitModel]) -> Void) {
        let network = RestfulAPI<EMPTYMODEL,Generic<UnitsModel>>.init(path: "/jobber/unit/all")
            .with(auth: .jobber)
            
        handleRequestByUI(network) { (response) in
            completion(response.data?.items ?? [])
        }
    }
    
    private func searchFetch(searchTitle: String, completion: @escaping (_ items: [UnitModel]) -> Void) {
        struct Search: Codable {
            let s: String
        }
        
        let network = RestfulAPI<Search,Generic<UnitsModel>>.init(path: "/jobber/unit/search")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: Search(s: searchTitle))
        handleRequestByUI(network) { (response) in
            completion(response.data?.items ?? [])
        }
    }

    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, UnitModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,UnitModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()
        
        tableViewDataSource = UITableViewDiffableDataSource.init(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)!
            
            cell.textLabel?.text = item.title?.firstUppercased
            
            if item.id == nil {cell.imageView?.image = UIImage(systemName: "plus")
            } else { cell.imageView?.image = nil }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func handleFetchedItems(_ items: [UnitModel], searchTitle: String) {
        let currentSnapshotItems = snapshot.itemIdentifiers
        var allItems = currentSnapshotItems + items
        
        let sameItems = allItems.filter { (item) -> Bool in
            let lowerCaseItemWithNoSpaced = item.title?.toNonQuotes().lowercased().replacingOccurrences(of: " ", with: "")
            let lowerCaseSearchTitleWithNoSpaced = searchTitle.toNonQuotes().lowercased().replacingOccurrences(of: " ", with: "")

            return (lowerCaseItemWithNoSpaced == lowerCaseSearchTitleWithNoSpaced)
        }

        if sameItems.count != 1 { allItems.append(UnitModel(id: nil, title: searchTitle)) }
        
        var updatedSnapshot = NSDiffableDataSourceSnapshot<Section, UnitModel>()
        
        updatedSnapshot.appendSections([.main])
        updatedSnapshot.appendItems(allItems, toSection: .main)
                
        snapshot = updatedSnapshot
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func removeSpaceFrom(title: String?) -> String {
        return title?.replacingOccurrences(of: " ", with: "") ?? ""
    }
    
    private func fetchResult(searchTitle: String) {
        //1. send request to server...
        //2. when response comming, insert the response to this method
        searchFetch(searchTitle: searchTitle) { [weak self] (items) in
            guard let self = self else { return }
            
            self.handleFetchedItems(items, searchTitle: searchTitle)
        }
    }
    
    
    @objc private func rightBarButtonTapped() {
        searchController.searchBar.searchTextField.placeholder = "Write your unit name".localized()
        searchController.isActive = true
        searchController.searchBar.searchTextField.becomeFirstResponder()
    }

    @objc private func fetchMatchingItems() {
        // search word if not empty
        let searchTerm = searchController.searchBar.text ?? ""
        guard searchTerm.isEmpty == false else { return }
        // clear data sources
        snapshot.deleteAllItems()
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        // fetch from server and reload snapshot
        fetchResult(searchTitle: searchTerm)
    }
}

extension JobberUnitListTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // observer for fetch data aftar delay 1 second.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 1)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // refresh all results again:
        searchController.searchBar.searchTextField.placeholder = searchPlaceholder
        fetchAllUnits()
    }
}

extension JobberUnitListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = snapshot.itemIdentifiers
        var item = items[indexPath.item]
        
        item.title = removeSpaceFrom(title: item.title)
        delegate?.selectedUnit(item)
        searchController.isActive = false
        
        dismiss(animated: true)
    }
}
