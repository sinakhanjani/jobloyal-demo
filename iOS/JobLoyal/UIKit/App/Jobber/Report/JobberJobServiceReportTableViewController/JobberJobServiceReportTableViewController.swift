//
//  JobberJobServiceTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit
import RestfulAPI

class JobberJobServiceReportTableViewController: JobberTableViewController {

    enum Section: Hashable {
        case accepted
        case rejected
    }
    
    @IBOutlet weak var totalPriceLabel: UILabel!
        
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,JobberRequestServiceModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberRequestServiceModel>()
    
    private var items: [JobberRequestServiceModel] = []
    public var reportID: String?
    public var tag: String?
    
    private var address: String?
    private var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        navigationItem.largeTitleDisplayMode = .always
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        perform()
        fetch(reportID: reportID)
    }
    
    private func fetch(reportID: String?) {
        guard let reportID = reportID else { return }
        
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberJobServiceReportModel>>.init(path: "/jobber/report/\(reportID)")
            .with(auth: .jobber)
        
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }
            
            let totalPrice = response.data?.services?
                .filter({ (item) -> Bool in
                    let isRejected = (!(item.accepted ?? false) && (self.tag == "accepted")) || (self.tag != "accepted")
                    
                    return !isRejected
                })
                .reduce(0.0, { (oldValue, currentValue) -> Double in
                let currentPrice = currentValue.price
                
                return oldValue + currentPrice
            })
            
            self.totalPriceLabel.text = "\((totalPrice ?? 0.0).toPriceFormatter)"
            self.date = response.data?.createdAt
            self.address = response.data?.address
            self.items = (response.data?.services ?? []).sorted(by: { (lhd, rhs) -> Bool in
                (lhd.accepted ?? false)
            })
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JobberRequestServiceModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberRequestServiceModel>()

        let acceptedItems = items.filter({ (item) -> Bool in
            let isRejected = (!(item.accepted ?? false) && (self.tag == "accepted")) || (self.tag != "accepted")
            
            return !isRejected
        })
        let rejectedItems = items.filter({ (item) -> Bool in
            let isRejected = (!(item.accepted ?? false) && (self.tag == "accepted")) || (self.tag != "accepted")
            
            return isRejected
        })
        
        if !acceptedItems.isEmpty {
            snapshot.appendSections([.accepted])
            snapshot.appendItems(acceptedItems, toSection: .accepted)
        }
        if !rejectedItems.isEmpty {
            snapshot.appendSections([.rejected])
            snapshot.appendItems(rejectedItems, toSection: .rejected)
        }

        return snapshot
    }
    
    private func perform() {
        self.snapshot = self.createSnapshot()
        tableViewDataSource = UITableViewDiffableDataSource<Section,JobberRequestServiceModel>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: JobberJobServiceReportTableViewCell.identifier) as! JobberJobServiceReportTableViewCell
            let isRejected = (!(item.accepted ?? false) && (self.tag == "accepted")) || (self.tag != "accepted")

            cell.updateUI(address: self.address ?? "-", date: self.date?.to(date: "dd/MM/YYYY HH:mm") ?? "-", jobTitle: item.title ?? "-", price: item.price, count: item.count, unit: item.unit)
            
            if isRejected {
                cell.backgroundColor = .heavyRed
            }
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}

extension JobberJobServiceReportTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = snapshot.sectionIdentifiers[section]
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        titleLabel.textColor = UIColor.label

        titleLabel.text = (section == .accepted) ? "Accepted Services".localized(): "Rejected Services".localized()
                
        return titleLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}
