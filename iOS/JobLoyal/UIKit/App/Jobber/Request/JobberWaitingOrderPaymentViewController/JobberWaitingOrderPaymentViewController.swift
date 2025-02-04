//
//  JobberOrderPaymentWaitingViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

class JobberWaitingOrderPaymentViewController: JobberViewController, PopupConfiguration {

    enum Section: Hashable {
        case main
        case service
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public var item: JobberAcceptJobStatusModel?
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,JobberAccpetRequestItem>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberAccpetRequestItem>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.3, options: []) {
            self.bgView.alpha = 0.9
        }
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private func configUI() {
        perform()
    }

    private func updateUI() {
        if let item = item {
            let name = item.user?.name?.firstUppercased ?? "Unkown".localized()
            nameLabel.text = name
            descriptionLabel.text = item.timeBase ? "Ask".localized() + " \(name) " + "to open the jobloyal and pay your mony now".localized():"Ask".localized() + " \(name) " + "to open the jobloyal and verify your job to get the mony on your wallet".localized()
        }
        
        snapshot = createSnapshot()
        tableViewDataSource.apply(snapshot)
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JobberAccpetRequestItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberAccpetRequestItem>()
        snapshot.appendSections([.service, .main])
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
                if let totalTimeInterval = item.totalTimeInterval {
                    let totalTimeWorked = TimerHelper.time(totalTimeInterval*60)
                    cell.updateUI(time: "\(totalTimeWorked.hour):\(totalTimeWorked.minute)", price: "\(item.total)", underPriceName: "Income".localized(), underTimeName: "Total Time".localized(), name: nil)
                }
                
                return cell
            case .service(let service): //
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestTableViewCell.identifier) as! JobberAcceptRequestTableViewCell
                cell.updateUI(serviceName: service.title ?? "-", unitName: service.unit, price: service.price)
                
                return cell
            default: return UITableViewCell()
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    private func dismiss() {
        // dismiss vc and go to next step
        fetchOpenOrder()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        let alertContent = AlertContent(title: .cancel, subject: "Cancel Request".localized(), description: "Do you want to cancel this request?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.cancelOrderRequest { [weak self] in
                DispatchQueue.main.async { self?.dismiss() }
            }
        }
        
        present(alertVC.prepare(alertVC.interactor))
    }
    
    deinit {
        jobberIdentifierHandler.remove(identifier: String(describing: self))
    }
}

extension JobberWaitingOrderPaymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .service: return UITableView.automaticDimension
        case .main: return 90
        }
    }
}
