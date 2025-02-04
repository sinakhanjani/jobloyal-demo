//
//  JobberJobServiceTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/4/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

class JobberJobServiceTableViewController: JobberTableViewController {
    
    enum Section {
        case main
        case service
        case add
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,JoberJobServiceItem>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JoberJobServiceItem>()
    
    private var items: [JoberJobServiceItem] = []
    
    public var jobID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchJobberJobDetail(jobID: jobID, animated: false)
    }
    
    private func updateUI() {
        navigationItem.largeTitleDisplayMode = .always
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        perform()
    }
    
    private func removeJobberJobRequest(jobID: String) {
        
    }
    
    private func removeServiceRequest(serviceID: String, isLastJobService: Bool = false) {
        struct SendRemoveServiceModel: Codable { let serviceId: String }
        let network = RestfulAPI<SendRemoveServiceModel,Generic<EMPTYMODEL>>.init(path: "/jobber/service/delete")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendRemoveServiceModel(serviceId: serviceID))
        
        handleRequestByUI(network) { [weak self] (resposne) in
            guard let self = self else { return }
            if let jobID = self.jobID, isLastJobService {
                self.removeJobRequest(jobID: jobID)
            }
            self.fetchJobberJobDetail(jobID: self.jobID, animated: true)
        }
    }
    
    private func removeJobRequest(jobID: String) {
        // after delete the job , go back to root nc
        struct SendRemoveJobberJobModel: Codable { let job_id: String }
        
        let network = RestfulAPI<SendRemoveJobberJobModel,Generic<EMPTYMODEL>>.init(path: "/jobber/job/delete")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendRemoveJobberJobModel(job_id: jobID))
        
        handleRequestByUI(network) { [weak self] (response) in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func fetchJobberJobDetail(jobID: String?, animated: Bool) {
        guard let jobID = jobID else { return }
        
        func convertToSwiftModel(_ model: JobberJobDetailModel) {
            self.items = []
            self.items.append(.detail(totalIncome: Double(model.totalIncome ?? "0.0")!, doneJob: model.workCount ?? 0, allRequests: model.requestCount ?? 0))
            self.items.append(.rate(from: model.totalComments ?? 0, averageRate: Double(model.rate ?? "0.0")!))
            if let services = model.services {
                let jobberJobServiceItems = services.map { JoberJobServiceItem.service(name: $0.title, unitName: $0.unit, price: $0.price, id: $0.id) }
                self.items.append(contentsOf: jobberJobServiceItems)
            }
            
            snapshot = createSnapshot()
            tableViewDataSource.apply(snapshot)
        }
        
        struct SendJobberJobDetailModel: Codable { let job_id: String }
        
        let network = RestfulAPI<SendJobberJobDetailModel,Generic<JobberJobDetailModel>>.init(path: "/jobber/job/page")
            .with(body: SendJobberJobDetailModel(job_id: jobID))
            .with(auth: .jobber)
            .with(method: .POST)
        
        handleRequestByUI(network, animated: animated) { (response) in
            if let data = response.data {
                convertToSwiftModel(data)
            }
        }
    }
    
    private func filterServices(_ filter: Bool) -> [JoberJobServiceItem] {
        let servicesItem = items.filter { (item) -> Bool in
            switch item {
            case .service(_,_,_,_): return filter
            default: return !filter
            }
        }
        
        return servicesItem
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JoberJobServiceItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JoberJobServiceItem>()
                
        let filterOtherServices = self.filterServices(false)
        if !filterOtherServices.isEmpty {
            snapshot.appendSections([.main])
            snapshot.appendItems(filterOtherServices, toSection: .main) // daynamic
        }
        
        snapshot.appendSections([.service,.add])
        snapshot.appendItems(filterServices(true), toSection: .service) // dynamic
        snapshot.appendItems([.add], toSection: .add) // static

        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()
        
        registerTableViewCell(tableView: tableView, cell: DetailTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: ServiceTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: AddTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: RateTableViewCell.self)

        tableViewDataSource = UITableViewDiffableDataSource.init(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            let cell = item.cell(tableView, indexPath: indexPath)

            if let cell = cell as? RateTableViewCell { cell.delegate = self }
            if let cell = cell as? ServiceTableViewCell { cell.delegate = self }
            if let cell = cell as? AddTableViewCell { cell.delegate = self }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension JobberJobServiceTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? ServiceTableViewCell {
            // selected service for edit
            // Only for numeric services.
            let item = items[indexPath.item]
            
            switch item {
            case let .service(_,_,_,id): print(id)
            default: break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = snapshot.sectionIdentifiers[indexPath.section]
        
        switch section {
        case .main: return UITableView.automaticDimension
        case .service: return UITableView.automaticDimension
        case .add: return 48
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = snapshot.sectionIdentifiers[section]
        
        if section == .main {
            let titleLabel = UILabel(frame: CGRect.zero)
            
            titleLabel.font = UIFont.avenirNextMedium(size: 17)
            titleLabel.textColor = UIColor.label

            if section == .main {
                titleLabel.text = "Job Detail".localized()
            }
                    
            return titleLabel
        }
        
        if section == .service {
            return JobberJobServiceTableFooterView()
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = snapshot.sectionIdentifiers[section]

        switch section {
        case .main: return 44
        case .service: return 88
        case .add: return 0
        }
    }
}

extension JobberJobServiceTableViewController: ServiceTableViewCellDelegate {
    func deleteButtonTapped(cell: ServiceTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            // Only for Service:
            let section = snapshot.sectionIdentifiers[indexPath.section] // indexPath.section == 1
            let services = filterServices(true)
            let service = services[indexPath.item]

            guard section == .service else { return } // Service Section
            guard !services.isEmpty else { return }
            
            switch service {
            case let .service(_,_,_,id):
                let isLastJobService = filterServices(true).count == 1
                var alertContent: AlertContent!
                
                if isLastJobService {
                    // warning the last item
                    alertContent = AlertContent(title: .delete, subject: "Delete Job and Service".localized(), description: "If you remove the last service; this job remove compeletly, Do you want to continue?".localized())
                } else {
                    // warning delete item
                    alertContent = AlertContent(title: .delete, subject: "Delete Service".localized(), description: "Are you sure you want to remove this service?".localized())
                }
                
                let alertVC = AlertContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                alertVC.yesButtonTappedHandler = { [weak self] in
                    if isLastJobService {
                        // remove service and remove the job here:
                        self?.removeServiceRequest(serviceID: id, isLastJobService: true)
                    } else {
                        // onlny remove service here
                        self?.removeServiceRequest(serviceID: id)
                    }
                }

                present(alertVC.prepare(alertVC.interactor),
                        animated: true)
            default: break
            }
        }
    }
}

extension JobberJobServiceTableViewController: AddTableViewCellDelegate {
    func addServiceButtonTapped() {
        let vc = JobberServiceListTableViewController
            .instantiateVC(.jobber)
        
        vc.jobID = jobID
        vc.title = title
        
        show(vc, sender: nil)
    }
}

extension JobberJobServiceTableViewController: RateTableViewCellDelegate {
    func commentButtonTapped() {
        // Go to commentVC designed in main interface.
        let vc = CommentTableViewController
            .instantiateVC()
        
        vc.jobID = jobID
        
        show(vc, sender: nil)
    }
}
