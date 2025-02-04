//
//  JobberAcceptRequestTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/7/1400 AP.
//

import UIKit
import MapKit
//import Popup
import RestfulAPI

class JobberAcceptRequestTableViewController: JobberTableViewController {

    struct RCUserCoordinateModel: Codable { let latitude: Double ; let longitude: Double }
    enum Section: Hashable {
        case main
        case service
        case arrivalTime
        case map
    }
    
    @IBOutlet weak var sendButton: UIButton!
    
    private var tableViewDataSource: JobberAcceptRequestDiffableDataSource!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberOrderItem>()
    
    public var item: JobberRequestModel?
    
    private var userCoordinate: RCUserCoordinateModel?
    private var arrivalTime: Int = 5
        
    let timerLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: .zero, y: .zero, width: 120, height: 58))
        label.text = ""
        label.font = UIFont.avenirNextMedium(size: 28)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        
        return label
    }()
    
    private var timerHelper: TimerHelper?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(cnlReceiveRemoteNotification(_:)), name: .cnlReceiveRemoteNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    private func configUI() {
        navigationItem.largeTitleDisplayMode = .always
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        navigationItem.titleView = timerLabel
        perform()
    }
    
    private func updateUI() {
        if let item = item {fetchUseLocationRequest(reqID: item.id) }
    }
    
    private func fetchUseLocationRequest(reqID: String) {
        let netowrk = RestfulAPI<EMPTYMODEL,Generic<RCUserCoordinateModel>>.init(path: "/jobber/request/location/\(reqID)")
            .with(auth: .jobber)
            
        handleRequestByUI(netowrk) { [weak self] (response) in
            guard let self = self else { return }
            self.userCoordinate = response.data
            self.snapshot.reloadSections([.map])
            self.tableViewDataSource.apply(self.snapshot)
        }
    }
    
    private func prepareTimer() {
        guard let item = item else { return }
        
        timerHelper = nil
        timerHelper = TimerHelper(elapsedTimeInSecond: Int(item.remainingTime))
        timerHelper?.start { [weak self] (secend, minute) in
            guard let self = self else { return }
            self.timerLabel.text = "\(minute):\(secend)"
            
            if self.timerHelper!.elapsedTimeInSecond <= 10 {
                self.timerLabel.textColor = .heavyRed
                self.timerLabel.font = UIFont.avenirNextBold(size: 28)
                self.timerLabel.alpha = .zero
                UIView.animate(withDuration: 1, delay: .zero, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.repeat,.autoreverse, .allowUserInteraction]) {
                    self.timerLabel.alpha = 1
                }
            }
            
            if self.timerHelper!.elapsedTimeInSecond == .zero { self.navigationController?.popViewController(animated: true) }
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JobberOrderItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberOrderItem>()
        snapshot.appendSections([.main, .service, .arrivalTime, .map])
        
        if let item = item {
            let services = item.services.map({ JobberOrderItem.service(item: $0) })
            
            snapshot.appendItems([.detail(item: item)], toSection: .main)
            snapshot.appendItems(services, toSection: .service)
            snapshot.appendItems([.arrivalTime], toSection: .arrivalTime)
            snapshot.appendItems([.map(lat: userCoordinate?.latitude ?? 0.0, long: userCoordinate?.longitude ?? 0.0, address: item.address ?? "-")], toSection: .map)
        }
        
        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()
        
        tableViewDataSource = JobberAcceptRequestDiffableDataSource(tableView: tableView, arivalTimeCellDelegate: self)
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func acceptJobRequest(reqID: String, serviceIDs: [Int], arrivalTime: Int) {
        struct SendAcceptModel: Codable { let request_id: String ; let accepted_services: [Int] ; let arrival_time: Int }
        struct RCAcceptModel: Codable { let user_time_paying: Int }

        let netowrk = RestfulAPI<SendAcceptModel,Generic<RCAcceptModel>>.init(path: "/jobber/request/accept")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendAcceptModel(request_id: reqID, accepted_services: serviceIDs, arrival_time: arrivalTime))
        
        handleRequestByUI(netowrk, disable: [sendButton]) { [weak self] (response) in
            guard let self = self else { return }
            JobloyalCongfiguration.Time.userTimePaying = response.data?.user_time_paying ?? 180
            self.navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.fetchOpenOrder()
            }
        }
    }
    
    // @IBACTION
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard self.arrivalTime != 0 else {
            let alertContent = AlertContent(title: .none, subject: "Bad Arrival Time".localized(), description: "Please select arrival time".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(warningVC.prepare(warningVC.interactor),animated: true)
            return
        }
        guard let item = item else { return }
        
        let serviceIDs: [Int] = item.services.filter { $0.id != nil }.map { $0.id! } // [Int] ids
        acceptJobRequest(reqID: item.id, serviceIDs: serviceIDs, arrivalTime: arrivalTime)
    }
}

class JobberAcceptRequestDiffableDataSource:UITableViewDiffableDataSource<JobberAcceptRequestTableViewController.Section,JobberOrderItem> {
    init(tableView: UITableView, arivalTimeCellDelegate: JobberAcceptRequestTimerTableViewCellDelegate) {
        super.init(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            
            switch item {
            case .detail(let item) where (item.services.count > 0) && (item.services.first?.unit != nil): // numeric cell
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberJobRequestNumericDetailTableViewCell.identifier) as! JobberJobRequestNumericDetailTableViewCell
                cell.updateUI(jobName: item.jobTitle ?? "-", distance: "\(item.distance ?? 0.0)", addressName: item.address ?? "-", totalPrice: item.price ?? "-")
                
                return cell
            case .detail(let item): // hour cell
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberJobRequestHourDetailTableViewCell.identifier) as! JobberJobRequestHourDetailTableViewCell
                cell.updateUI(jobName: item.jobTitle ?? "-", distance: "\(item.distance ?? 0.0)", addressName: item.address ?? "-")
                
                return cell
            case .service(let service): // service
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestTableViewCell.identifier) as! JobberAcceptRequestTableViewCell
                cell.updateUI(serviceName: service.title ?? "-", unitName: service.unit, price: service.price)
                
                return cell
            case .arrivalTime:
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestTimerTableViewCell.identifier) as! JobberAcceptRequestTimerTableViewCell
                cell.delegate = arivalTimeCellDelegate
                
                return cell
            case let .map (lat, long, address):
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestMapTableViewCell.identifier) as! JobberAcceptRequestMapTableViewCell
                let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                cell.updateUI(address: address)
                cell.configurationMap(userLocation: userLocation, regionRadius: 20000)
                
                return cell
            default: return UITableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let snapshot = self.snapshot()
        let sectionIdentifiers = snapshot.sectionIdentifiers
        let sectionIdentifier = sectionIdentifiers[section]
        
        if sectionIdentifier == .service { return "Services".localized() }
        if sectionIdentifier == .arrivalTime { return "Arival Time".localized() }
        if sectionIdentifier == .map { return "Location".localized() }
        
        return nil
    }
}

extension JobberAcceptRequestTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .arrivalTime: return 160
        default: return UITableView.automaticDimension
        }
    }
}

extension JobberAcceptRequestTableViewController: JobberAcceptRequestTimerTableViewCellDelegate {
    func didSelect(minute: Int) {
        arrivalTime = minute
    }
}

extension JobberAcceptRequestTableViewController: JobberRequestViewControllerDelegate {
    func userCanceledThe(_ job: JobberRequestModel) {
        if job.id == item?.id {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func cnlReceiveRemoteNotification(_ notification: Notification) {
        let userInfo = notification.userInfo
        // code remove request from the list.
        if let str = userInfo?["data"] as? String {
            if let data = str.data(using: .utf8) {
                struct Req: Codable { let request_id: String? }
                if let req = try? JSONDecoder().decode(Req.self, from: data) {
                    if let reqID = req.request_id {
                        if reqID == item?.id {
                            navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}
