//
//  UserJobberJobHourTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/20/1400 AP.
//

import UIKit
//import Popup
import CoreLocation
import RestfulAPI

class UserJobberJobHourTableViewController: UserTableViewController {

    enum Section: Hashable {
        case main
    }
        
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    public var items: [ServiceJobModel] = []
    public var jobberListModel: RCJobberListModel?
    public var coordinate: CLLocationCoordinate2D?
    
    private let slideDownTransitionAnimator = SlideDownTransitionAnimator()

    private var tableViewDataSource: UITableViewDiffableDataSource<Section,ServiceJobModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, ServiceJobModel>()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Jobber Services".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,ServiceJobModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,ServiceJobModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
                
        return snapshot
    }
    
    private func sendJobRequest() {
        guard let jobberID = jobberListModel?.jobberID else { return }
        let sendServicesModel = items.map { item -> SendServiceRequestModel in
            return SendServiceRequestModel.init(id: item.id!, count: 0)
        }
        let body = SendUserjobRequestModel(latitude: coordinate?.latitude ?? 0.0, longitude: coordinate?.longitude ?? 0.0, jobberID: jobberID, services: sendServicesModel)
        let network = RestfulAPI<SendUserjobRequestModel,Generic<RCUserjobRequestModel>>.init(path: "/user/request/add")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(network, disable: [sendButton]) { [weak self] (response) in
            guard let self = self else { return }
            self.fetchOpenOrder()
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func perform() {
        // Regiser cell:
        registerTableViewCell(tableView: tableView, cell: UserJobberJobHourTableViewCell.self)
        
        snapshot = createSnapshot()
        
        tableViewDataSource = UITableViewDiffableDataSource<Section,ServiceJobModel>(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberJobHourTableViewCell.identifier) as! UserJobberJobHourTableViewCell
            cell.updateUI(price: item.price ?? 0.0, title: item.title ?? "-")
            self?.totalPriceLabel.text = "\((item.price ?? 0.0).toPriceFormatter) CHF"
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    
    @IBAction func nextAndRequestButtonTapped(_ sender: Any) {
        sendJobRequest()
    }
}

extension UserJobberJobHourTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        titleLabel.textColor = UIColor.label
        titleLabel.text = "Service - Per Hour".localized()
                
        return titleLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let userJobberJobNumericOrHourFooterTableViewSection = UserJobberJobNumericOrHourFooterTableViewSection()
        userJobberJobNumericOrHourFooterTableViewSection.descriptionLabel.text = "You request the jobber and wait for anwer, if the jobber accept your request he go to you and the end of his work you ask him to pay".localized()
        
        return userJobberJobNumericOrHourFooterTableViewSection
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        140
    }
}
