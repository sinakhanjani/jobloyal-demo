//
//  UserJobberJobTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/19/1400 AP.
//

import UIKit
import CoreLocation
import RestfulAPI

class UserJobberJobTableViewController: UserTableViewController {
    enum Section: Hashable {
        case info
        case serviceNumeric
        case serviceHour
        case comment
    }
    
    enum Item: Hashable {
        case info(RCJobberJobModel)
        case serviceNumeric(ServiceJobModel)
        case serviceHour(ServiceJobModel)
        case comment(CommentModel)
    }
        
    public var item: RCJobberJobModel?
    public var jobberListModel: RCJobberListModel?
    public var coordinate: CLLocationCoordinate2D?
    
    private var selectedServices: [ServiceJobModel] = []

    private var tableViewDataSource: UITableViewDiffableDataSource<Section,Item>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    private var tableFooterView =  UserJobberJobNextStepView(height: 72)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Jobber Info".localized()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let nextButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(nextButtonTapped))
        tableFooterView.addGestureRecognizer(nextButtonTapGesture)
        fetch()
        perform()
    }
    
    private func fetch() {
        guard let jobberListModel = self.jobberListModel else { return }
        guard let jobID = jobberListModel.jobID, let jobberID = jobberListModel.jobberID else {
            return
        }
        guard let coordinate = self.coordinate else { return }
        let body = SendJobberJobModel(jobberID: jobberID, jobID: jobID, latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude))
        let netowrk = RestfulAPI<SendJobberJobModel,Generic<RCJobberJobModel>>.init(path: "/user/jobber/page")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(netowrk) { [weak self] (response) in
            guard let self = self else { return }

            self.item = response.data
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        
        snapshot.appendSections([.info])
        if let item = item {
            snapshot.appendItems([.info(item)], toSection: .info)
            
            if let services = item.services, !services.isEmpty {
                let numericServices = services.filter { $0.unit != nil }
                let convertedNumericServices = numericServices.map { Item.serviceNumeric($0) }
                if !convertedNumericServices.isEmpty {
                    snapshot.appendSections([.serviceNumeric])
                    snapshot.appendItems(convertedNumericServices, toSection: .serviceNumeric)
                }
                
                let hourServices = services.filter { $0.unit == nil }
                let convertedHourServices = hourServices.map { Item.serviceHour($0) }
                if !convertedHourServices.isEmpty {
                    snapshot.appendSections([.serviceHour])
                    snapshot.appendItems(convertedHourServices, toSection: .serviceHour)
                }
            }
            
            if let comments = item.comments, !comments.isEmpty {
                let convertedComments = comments.map { Item.comment($0) }
                
                snapshot.appendSections([.comment])
                snapshot.appendItems(convertedComments, toSection: .comment)
            }
        }
        
        return snapshot
    }
    
    private func perform() {
        // Regiser cell:
        registerTableViewCell(tableView: tableView, cell: UserJobberJobInfoTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: UserJobberJobServiceNumericTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: UserJobberJobServiceHourTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: CommentTableViewCell.self)
                
        tableViewDataSource = UITableViewDiffableDataSource<Section,Item>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            switch item {
            case .info(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberJobInfoTableViewCell.identifier) as! UserJobberJobInfoTableViewCell
                
                cell.updateUI(shortFullyName: item.avatar ?? "-", jobberUsername: item.identifier ?? "-", workedNumber: item.workCount ?? 0, distance: item.distance ?? 0.0, commentCount: item.totalComments ?? 0, rate: Double(item.rate ?? "0.0") ?? 0.0, jobberDescription: item.aboutMe ?? "-")
                
                return cell
            case .serviceNumeric(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberJobServiceNumericTableViewCell.identifier) as! UserJobberJobServiceNumericTableViewCell
                
                cell.updateUI(title: item.title ?? "", price: item.price ?? 0.0)
                cell.accessoryType = self.selectedServices.contains(item) ? .checkmark:.none
                
                return cell
            case .serviceHour(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberJobServiceHourTableViewCell.identifier) as! UserJobberJobServiceHourTableViewCell
                
                cell.updateUI(title: item.title ?? "-", price: item.price ?? 0.0)
                
                return cell
            case .comment(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier) as! CommentTableViewCell
                
                cell.updateUI(subject: item.service_title ?? "-", description: item.comment ?? "-", rating: Double(item.rate ?? "0.0") ?? 0.0)
                
                return cell
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    @objc func moreCommentButtonTapped() {
        let vc = CommentTableViewController.instantiateVC()
        
        vc.jobberID = jobberListModel?.jobberID
        vc.jobID = jobberListModel?.jobID
        
        show(vc, sender: nil)
    }
    
    @objc func nextButtonTapped() {
        let vc = UserJobberJobNumericTableViewController.instantiateVC(.user)
        
        vc.items = selectedServices
        vc.jobberListModel = jobberListModel
        vc.coordinate = coordinate
        
        show(vc, sender: nil)
    }
}

extension UserJobberJobTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = snapshot.sectionIdentifiers[indexPath.section]
        
        switch section {
        case .info:
            break
        case .serviceNumeric:
            let items = self.snapshot.itemIdentifiers(inSection: .serviceNumeric)
            let item = items[indexPath.item]
            if case .serviceNumeric(let service) = item {
                let index = selectedServices.lastIndex(where: { (i) -> Bool in
                    return service.id == i.id
                })
                
                if let index = index {
                    selectedServices.remove(at: index)
                } else {
                    selectedServices.append(service)
                }
                
                tableFooterView.titleLabel.text =  "\(selectedServices.count) " + "Service(s) selected".localized()
                tableView.tableFooterView = selectedServices.isEmpty ? nil:tableFooterView
                snapshot.reloadItems([item])
                tableViewDataSource.apply(snapshot)
            }
            break
        case .serviceHour:
            if self.snapshot.sectionIdentifiers.contains(.serviceNumeric) {
                self.selectedServices = []
                tableViewDataSource.apply(snapshot)
            }
            
            let items = self.snapshot.itemIdentifiers(inSection: .serviceHour)
            let item = items[indexPath.item]
            
            if case .serviceHour(let service) = item {
                let vc = UserJobberJobHourTableViewController.instantiateVC(.user)
                vc.items = [service]
                vc.jobberListModel = jobberListModel
                vc.coordinate = coordinate
                
                show(vc, sender: nil)
            }
        case .comment: break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionItem = snapshot.sectionIdentifiers[section]
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        titleLabel.textColor = UIColor.label
        
        switch  sectionItem {
        case .info:
            titleLabel.text = "Information".localized()
        case .serviceNumeric:
            let headerView = UserJobberJobTableHeaderView(title: "Services - Numeric".localized(), body: "You can select one or more numeric services to do the job".localized())
            
            return headerView
        case .serviceHour:
            let headerView = UserJobberJobTableHeaderView(title: "Services - Per Hour", body: "You can only select one per hour service to do the job".localized())
            
            return headerView
        case .comment:
            titleLabel.text = "User Comments".localized()
        }
                
        return titleLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = snapshot.sectionIdentifiers[section]
        
        switch section {
        case .serviceNumeric: return 88
        case .serviceHour: return 88
        default: return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionItem = snapshot.sectionIdentifiers[section]
        guard sectionItem == .comment else { return nil }
        let moreButton = UIButton()
        
        moreButton.frame = CGRect(x: .zero, y: .zero, width: .zero, height: 44)
        moreButton.setTitle("More Comments".localized(), for: .normal)
        moreButton.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        moreButton.setTitleColor(.heavyBlue, for: .normal)
        moreButton.titleLabel?.textAlignment = .center
        moreButton.addTarget(self, action: #selector(moreCommentButtonTapped), for: .touchUpInside)
        
        return moreButton
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionItem = snapshot.sectionIdentifiers[section]
        guard sectionItem == .comment else { return 0 }
        
        return 48
    }
}
