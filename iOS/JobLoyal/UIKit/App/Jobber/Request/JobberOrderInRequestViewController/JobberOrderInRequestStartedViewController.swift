//
//  JobberOrderInRequestViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

class JobberOrderInRequestStartedViewController: JobberViewController, PopupConfiguration {
    
    enum Section: Hashable {
        case main
        case service
    }
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var serviceButton: AppButton!
    
    public var item: JobberAcceptJobStatusModel?
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,JobberAccpetRequestItem>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberAccpetRequestItem>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        perform()
    }

    private func updateUI() {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.3, options: []) {
            self.bgView.alpha = 0.9
        }

        let isNumeric = !(item?.timeBase ?? true)
        let buttonTitle = isNumeric ?  "I Finished The Service".localized():"I Finished The Service(s)".localized()
        
        serviceButton.setTitle(buttonTitle, for: .normal)
        serviceButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: [.selected,.highlighted])
        serviceButton.backgroundColor = .heavyGreen
        
        snapshot = createSnapshot()
        tableViewDataSource.apply(snapshot)
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JobberAccpetRequestItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberAccpetRequestItem>()
        snapshot.appendSections([.main, .service])
        if let item = item {
            let services = item.services.map({ JobberAccpetRequestItem.service(item: $0) })
            snapshot.appendItems(services, toSection: .service)
            snapshot.appendItems([.base(item: item)], toSection: .main)
        }

        return snapshot
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource<Section,JobberAccpetRequestItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .base(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberOrderDetailRequestTableViewCell.identifier) as! JobberOrderDetailRequestTableViewCell
                if let status = item.status, let jobStatus = JobberJobStatus(rawValue: status) {
                    let underTimeName = jobStatus == .arrived ? "Arrived Time".localized():"Started Service".localized()
                    let time = item.updatedAt?.to(date: "HH:mm") ?? "-"
                    let isNumeric = !item.timeBase
                    cell.updateUI(time: time, price: "\(item.total)", underPriceName: isNumeric ? "Paid".localized():"Per Hour".localized(), underTimeName: underTimeName, name: item.user?.name ?? "-")
                }
                
                return cell
            case .service(let service): // service
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestTableViewCell.identifier) as! JobberAcceptRequestTableViewCell
                cell.updateUI(serviceName: service.title ?? "-", unitName: service.unit, price: service.price)
                
                return cell
            default: return UITableViewCell()
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.2) {
            self.bgView.alpha = 0.0
        }
        // dismiss vc and go to next step
        self.fetchOpenOrder()
    }
    
    private func finishServiceRequest() {
        let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/jobber/request/finish")
            .with(auth: .jobber)
            .with(method: .POST)
        
        handleRequestByUI(network, disable: [serviceButton]) { [weak self] (response) in
            self?.dismiss()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let alertContent = AlertContent(title: .cancel, subject: "Cancel Request".localized(), description: "Do you want to cancel this request?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.cancelOrderRequest { [weak self] in
                self?.dismiss()
            }
        }
        
        present(alertVC.prepare(alertVC.interactor))
    }
    
    @IBAction func startServiceButtonTapped(_ sender: Any) {
        finishServiceRequest()
    }
    
    deinit {
        jobberIdentifierHandler.remove(identifier: String(describing: self))
    }
}

extension JobberOrderInRequestStartedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .main: return 128
        case .service: return UITableView.automaticDimension
        }
    }
}
