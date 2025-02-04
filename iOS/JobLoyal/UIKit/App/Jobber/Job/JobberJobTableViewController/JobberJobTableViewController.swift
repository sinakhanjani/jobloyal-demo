//
//  JobTabViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/28/1400 AP.
//

import UIKit
import MapKit
import RestfulAPI

class JobberJobTableViewController: JobberTableViewController {
    
    enum Section {
        case main
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, JobberJobModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberJobModel>()
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?

    private var items: [JobberJobModel] = []
    private let emptyJobberModel = JobberJobModel(jobID: "jobID")
    private var shouldUpdateLocation: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirNextBold(size: 34), NSAttributedString.Key.foregroundColor: UIColor.label]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // fetch jobberJobItems
        fetchJobberJobItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        if let jobberToken = Auth.shared.jobber.token { print(jobberToken) }
        items = [emptyJobberModel]
        // update today label
        updateTodayDateLabel()
        // config job collection view
        perform()
        // update and config location
        configurationLocation()
        fetchLocationStatus(animated: true)
        // fetch open order in application for jobber
        fetchOpenOrder()
        fetchOpenOrderEvery(JobloyalCongfiguration.Time.fetchOrderDuration)
        // access for send notification
        (UIApplication.shared.delegate as! AppDelegate).requestForNotificationPrivacy()
        // configDailyUpdateJobsStatusNotification for online job every day
        if JobloyalCongfiguration.Notification.dailyUpdateJobStatus {
            JobloyalCongfiguration
                .Notification
                .dailyUpdateJob
                .fire(at: 7, and: 0)
        }
    }
        
    private func fetchJobberJobItems() {
        // send request: get all jobs of jobber here.
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberJobsModel>>.init(path: "/jobber/job/myjobs")
            .with(auth: .jobber)
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            // update data from server
            self.items = (response.data?.items ?? []).uniqued()
            self.items.append(self.emptyJobberModel)
            self.snapshot = self.createSnapshot()
            self.collectionViewDataSource.apply(self.snapshot)
        }
    }
    
    private func updateTodayDateLabel() {
        let date = Date()
        let dateFormmater = DateFormatter()
        
        dateFormmater.dateStyle = .medium
        dateLabel.text = dateFormmater.string(from: date)
    }
    
    private func changeJobStatus(_ isActive: Bool, jobID: String) {
        // MARK: - SendJobberStatusModel
        struct SendJobberStatusModel: Codable { let status: String ; let jobId: String }
        // MARK: - RCJobberStatusModel
        struct RCJobberStatusModel: Codable {
            let id: Int
            let status, jobberID, jobID, createdAt: String?

            enum CodingKeys: String, CodingKey {
                case id, status
                case jobberID = "jobber_id"
                case jobID = "job_id"
                case createdAt
            }
        }

        let status = isActive ? "online":"offline"
        let sendJobberStatus = SendJobberStatusModel(status: status, jobId: jobID)
        let network = RestfulAPI<SendJobberStatusModel,Generic<RCJobberStatusModel>>.init(path: "/jobber/status/add")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: sendJobberStatus)
        
        handleRequestByUI(network) { [weak self] (response) in
            self?.fetchJobberJobItems()
        }
    }
    
    private func fetchLocationStatus(animated: Bool) {
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberLocationStatus>>.init(path: "/jobber/status/location/get")
            .with(auth: .jobber)
        
        handleRequestByUI(network, animated: animated) { [weak self] (response) in
            guard let self = self, let data = response.data else { return }

            self.addressLabel.text = data.address
            self.updateDateLabel.text = "Last Update".localized() + ": " + (data.createdAt?.to(date: "HH:mm") ?? "-")
            self.shouldUpdateLocation = data.shouldUpdate
            
            if (data.shouldUpdate ?? true) {
                let alertContent = AlertContent(title: .none, subject: "Update Location".localized(), description: "671-hja-B2a-N44".localized())
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                self.present(warningVC.prepare(warningVC.interactor),animated: true)
                
                return
            }
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, JobberJobModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberJobModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main) // 0 == AddNewJobCell
        
        return snapshot
    }
    
    private func perform() {
        registerCollectionViewCell(collectionView: collectionView, cell: JobberJobCollectionViewCell.self)
        registerCollectionViewCell(collectionView: collectionView, cell: JobberJobAddNewJobCollectionViewCell.self)
        
        snapshot = createSnapshot()
        
        let cellCize: CGSize = CGSize(width: UIScreen.main.bounds.width-80, height: collectionView.bounds.height)
        
        collectionView.collectionViewLayout = CoAnimationCollectionViewFlowLayout(itemSize: cellCize)
        collectionViewDataSource = UICollectionViewDiffableDataSource<Section, JobberJobModel>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item.jobID {
            case self?.emptyJobberModel.jobID:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobberJobAddNewJobCollectionViewCell.identifier, for: indexPath) as! JobberJobAddNewJobCollectionViewCell

                 return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobberJobCollectionViewCell.identifier, for: indexPath) as! JobberJobCollectionViewCell
                cell.updateUI(title: item.title ?? "", numberOfSerivce: item.serviceConut ?? "", timeLine: item.statusCreatedTime)
                cell.isAvailable = (item.status == "online") ? true : false
                cell.delegate = self
                
                return cell
            }
        })
        
        collectionViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func updateLocationRequest(completion: @escaping () -> Void) {
        guard checkAccessGPS(locationManager: locationManager) else { return }
        guard let currentLocation = currentLocation else { return }
        let jobberLocation = JobberUpdateLocationModel(latitude: "\(currentLocation.latitude)", longitude: "\(currentLocation.longitude)")
        let network = RestfulAPI<JobberUpdateLocationModel,Generic<EMPTYMODEL>>.init(path: "/jobber/status/location/add")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: jobberLocation)
        
        self.handleRequestByUI(network) { [weak self] (response) in
            self?.fetchLocationStatus(animated: false)
            completion()
        }
    }
    
    @IBAction func updateLocationButtonTapped(_ sender: Any) {
        let alertContent = AlertContent(title: .none, subject: "Update Location".localized(), description: "Do you want to update your location?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        present(alertVC.prepare(alertVC.interactor),animated: true)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            self.updateLocationRequest { }
        }
    }
}

extension JobberJobTableViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func configurationLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let centerLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        currentLocation = centerLocation
    }
}

extension JobberJobTableViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        if item.jobID == emptyJobberModel.jobID {
            // Add new job
            let vc = JobberJobCategoryTableViewController.instantiateVC(.jobber)
            
            show(vc, sender: nil)
            return
        }

        let vc = JobberJobServiceTableViewController.instantiateVC(.jobber)
        vc.title = item.title
        vc.jobID = item.jobID
        
        show(vc, sender: nil)
    }
}

extension JobberJobTableViewController: JobberJobCollectionViewCellDelegate {
    func onlineButtonTapped(cell: JobberJobCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let item = items[indexPath.item]
            let isAvailable = (item.status == "online") ? true:false
            guard !isAvailable else {
                let alertContent = AlertContent(title: .update, subject: "Ops!".localized(), description: "This job is currently Online".localized())
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                present(warningVC.prepare(warningVC.interactor), animated: true)
                
                return
            }
            
            let alertContent = AlertContent(title: .update, subject: "Online".localized(), description: "Do you want to do your job online?".localized())
            let alertVC = AlertContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(alertVC.prepare(alertVC.interactor), animated: true)
            
            alertVC.yesButtonTappedHandler = { [weak self] in
                guard let self = self else { return }
                
                self.changeJobStatus(true, jobID: item.jobID)
            }
        }
    }

    func offlineButtonTapped(cell: JobberJobCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let item = items[indexPath.item]
            let isAvailable = (item.status == "online") ? true:false
            guard isAvailable else {
                let alertContent = AlertContent(title: .update, subject: "Ops!".localized(), description: "This job is currently offline".localized())
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                present(warningVC.prepare(warningVC.interactor), animated: true)
                
                return
            }
            let alertContent = AlertContent(title: .update, subject: "Offline".localized(), description: "Do you want to do your job offline?".localized())
            let alertVC = AlertContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(alertVC.prepare(alertVC.interactor), animated: true)
            
            alertVC.yesButtonTappedHandler = { [weak self] in
                guard let self = self else { return }
                
                self.changeJobStatus(false, jobID: item.jobID)
            }
        }
    }

    func serviceAndCommentsGestureTapped(cell: JobberJobCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let item = items[indexPath.item]
            let vc = CommentTableViewController.instantiateVC()
            vc.jobID = item.jobID
            
            show(vc, sender: nil)
        }
    }
}


extension JobberJobTableViewController: JobberServiceTableViewControllerDelegate {
    func newServiceAddedTo(_ jobID: String) {
        let shouldUpdateLocation = (shouldUpdateLocation ?? true)
        let index = items.lastIndex(where: { $0.jobID == jobID })
        
        if let index = index {
            let item = items[index]
            let isAvailable = (item.status == "online") ? true:false

            // location is out of date
            if shouldUpdateLocation {
                // warning message to show when a new service added to the job and location or job is not available
                var description: String = ""
                let availableMsg = "671-hja-B2a-N44".localized()
                let notAvailableMsg = "xhg-138-173-Vnc".localized()
            
                description = isAvailable ? availableMsg:notAvailableMsg
                
                let alertContent = AlertContent(title: .update, subject: "Update Status".localized(), description: description)
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                present(warningVC.prepare(warningVC.interactor), animated: true)
            } else {
                if (isAvailable == false) {
                    changeJobStatus(true, jobID: jobID)
                }
            }
        } else {
            // create new job
            // location is out of date
            if shouldUpdateLocation {
                let description = "xhg-138-173-Vnc".localized()
                let alertContent = AlertContent(title: .update, subject: "Update Status".localized(), description: description)
                let warningVC = WarningContentViewController
                    .instantiateVC()
                    .alert(alertContent)
                
                present(warningVC.prepare(warningVC.interactor), animated: true)
            } else {
                changeJobStatus(true, jobID: jobID)
            }
        }
    }
}
