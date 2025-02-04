//
//  UserJobCategoryViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/17/1400 AP.
//

import UIKit
import RestfulAPI

protocol UserJobCategoryViewControllerDelegate: UserViewController {
    func tableViewExpandChanged(_ state: Bool, vc: UserJobCategoryViewController)
    func parentVC() -> UserFindJobCategoryViewController
}

class UserJobCategoryViewController: UserViewController {
    
    enum Section {
        case main
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    public var isExpanded: Bool = false {
        willSet {
            delegate?.tableViewExpandChanged(newValue, vc: self)
            tableHeaderView.isExpanded = newValue
        }
    }
    
    private let unwindToUserFindJobViewController = "unwindToJuserFindJobViewController"
    
    private let tableHeaderView = UserJobCategoryHeaderTableView(height: 40)
    
    public var tableViewDataSource: UserJobCategoryTableViewDiffableDataSource!
    public var snapshot = NSDiffableDataSourceSnapshot<Section, UserJobCategoryItem>()
    
    public var items:[UserJobCategoryItem] = []
    public var selectedItem:UserJobCategoryItem?
    
    public weak var delegate: UserJobCategoryViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        tableHeaderView.titleLabel.text = "Category and Job".localized()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableHeaderViewTapped))
        tableHeaderView.addGestureRecognizer(tapGesture)
        tableView.tableHeaderView = tableHeaderView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        perform()
    }
    
    public func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,UserJobCategoryItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,UserJobCategoryItem>()

        snapshot.appendSections([.main])
        snapshot.appendItems(isExpanded ? items:[], toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        registerTableViewCell(tableView: tableView, cell: userJobCategoryServiceTableViewCell.self)
        
        snapshot = createSnapshot()
        
        tableViewDataSource = UserJobCategoryTableViewDiffableDataSource(tableView: tableView)
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    public func reload() {
        tableView.layoutIfNeeded()
        snapshot = createSnapshot()
        tableViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func presentSelf(items: [UserJobCategoryItem], navigationTitle: String) {
        let vc = UserJobCategoryViewController.instantiateVC(.user)
        
        vc.title = navigationTitle
        vc.items = items
        vc.isExpanded = true
        vc.delegate = delegate
        vc.delegate?.parentVC().delegate = self
        
        show(vc, sender: nil)
    }
    
    private func fetchJobIn(categoryID: String, navigationTitle: String) {
        struct SendJobCategoryModel: Codable { let category_id: String }
        
        let network = RestfulAPI<SendJobCategoryModel,Generic<JobberJobListsModel>>.init(path: "/user/jobs")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: SendJobCategoryModel(category_id: categoryID))
        // disable interaction of tableView
        tableView.isUserInteractionEnabled = false
        // fetch Items and show new view controller of Self
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }
            // enable interaction of tableView
            self.tableView.isUserInteractionEnabled = true
            let items = response.data?.items ?? []
            let convertedJobs = items.map { UserJobCategoryItem.job($0) }
            
            self.presentSelf(items: convertedJobs, navigationTitle: navigationTitle)
        }
    }
    
    public func handleFetchItems(results: [UserJobCategoryItem]) {
        self.items = results
        snapshot = createSnapshot()
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    public func fetchSearchResult(searchTitle: String) {
        struct SearchServiceModel: Codable { let s: String }

        let network = RestfulAPI<SearchServiceModel,Generic<UserJobberServicesModel>>.init(path: "/user/service/search")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: SearchServiceModel(s: searchTitle))
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            
            let items = response.data?.items ?? []
            let convertedServices = items.map { UserJobCategoryItem.service($0) }
            
            self.navigationController?.popToRootViewController(animated: true)
            self.handleFetchItems(results: convertedServices)
        }
    }
    
    @objc private func tableHeaderViewTapped() {
        isExpanded.toggle()
    }
    
    @objc private func fetchMatchingItems() {
        // search word if not empty
        let searchTerm = delegate?.parentVC().searchTextField.text ?? ""
        guard !searchTerm.isEmpty else {
            // you must fetchJobCategory() here again and reload your snapshot when searchTextField is empty:
            delegate?.parentVC().fetchJobCategory()
            return
        }
        // fetch from server and reload tableView snapshot
        fetchSearchResult(searchTitle: searchTerm)
    }
}

extension UserJobCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        switch item {
        case .category(let category):
            if let children = category.children {
                let convertedCategories = children.map { UserJobCategoryItem.category($0) }
                presentSelf(items: convertedCategories, navigationTitle: category.title)
                return
            }
            // present with job
            fetchJobIn(categoryID: category.id, navigationTitle: category.title)
            break
        case .job(let job):
            selectedItem = UserJobCategoryItem.job(job)
            performSegue(withIdentifier: unwindToUserFindJobViewController, sender: nil)
            break
        case .service(let service):
            selectedItem = UserJobCategoryItem.service(service)
            performSegue(withIdentifier: unwindToUserFindJobViewController, sender: nil)
            break
        }
    }
}

extension UserJobCategoryViewController: UserFindJobCategoryViewControllerDelegate {
    func searchTextFieldEditingChanged(_ sender: UITextField) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 0.6)
    }
}
