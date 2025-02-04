//
//  JobberRequestViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit
import MapKit
import RestfulAPI
//import Popup

protocol JobberRequestViewControllerDelegate: AnyObject {
    func userCanceledThe(_ job: JobberRequestModel)
}

class JobberRequestViewController: JobberViewController {
    
    enum Section {
        case main
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    // user current location
    private let locationManager = CLLocationManager()
    // dataSource
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, JobberRequestModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberRequestModel>()
    // timer for request
    private var timer: TimerHelper?
    private var fetchResultTimer: Timer?
    private weak var delegate: JobberRequestViewControllerDelegate?
    private var items: [JobberRequestModel] = []
        
    static public var isPresenting: Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultTimer?.invalidate()
        fetchResultTimer = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        JobberRequestViewController.isPresenting = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        JobberRequestViewController.isPresenting = true
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidEnterForeground), name: .sceneDidEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cnlReceiveRemoteNotification(_:)), name: .cnlReceiveRemoteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newReceiveRemoteNotification(_:)), name: .newReceiveRemoteNotification, object: nil)

        fetchResultEvery(JobloyalCongfiguration.Time.fechJobRequestDuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        configurationMap()
        perform()
    }
    
    private func fetchResultEvery(_ second: Double) {
        fetchResult()
        
        fetchResultTimer?.invalidate()
        fetchResultTimer = nil
        fetchResultTimer = Timer.scheduledTimer(withTimeInterval: second, repeats: true, block: { [weak self] _ in
            self?.fetchResult()
        })
    }
    
    private func filterEquatable(_ oldItems: [JobberRequestModel],_ newItems: [JobberRequestModel]) -> [JobberRequestModel] {
        var items = oldItems
        
        for newItem in newItems {
            if !oldItems.contains(newItem) {
                items.append(newItem)
            }
        }
        for (index,oldItem) in oldItems.enumerated() {
            if !newItems.contains(oldItem) {
                let job = items.remove(at: index)
                delegate?.userCanceledThe(job)
            }
        }
        
        return items
    }
    
    private func fetchResult() {
        let netowrk = RestfulAPI<EMPTYMODEL,Generic<JobberJobsRequestModel>>.init(path: "/jobber/request/myrequest")
            .with(auth: .jobber)
        
        handleRequestByUI(netowrk, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            // when data recieved from server call this and add data to self.items:
            // fetch data from server
            if let requestLifeTime = response.data?.requestLifeTime {
                JobloyalCongfiguration.Time.requestLifeTime = requestLifeTime
            }
            // newItems from server
            let newItems = response.data?.items ?? []
            // 1. put items = (ServerData)
            self.items = self.filterEquatable(self.items, newItems)
            // 2. start timer and reload snapshot for new data and control the duration interval: startRejectionTimeInterval()
            self.startRejectionTimeInterval()
        }
    }
    
    private func startRejectionTimeInterval() {
        func refreshData() {
            let newItems = items.map { item -> JobberRequestModel in
                let remainingTime = (item.remainingTime > 0) ? (item.remainingTime-1) : 0
                var newItem = item
                newItem.remainingTime = remainingTime
                
                return newItem
            }
            .filter({$0.remainingTime != 0})
            
            collectionView.backgroundView = (newItems.isEmpty) ? createEmptyRequestInboxView() : nil
            
            items = newItems
            snapshot = createSnapshot()
            collectionViewDataSource.apply(snapshot, animatingDifferences: false)
        }
        
        timer?.pauseTimer()
        timer = nil
        timer = TimerHelper(elapsedTimeInSecond: JobloyalCongfiguration.Time.requestLifeTime)
        timer!.start(completion: { _ in
            refreshData()
        })
    }
    
    private func createEmptyRequestInboxView() -> EmptyRequestInboxView {
        let emptyRequestInboxView = EmptyRequestInboxView()
        
        return emptyRequestInboxView
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, JobberRequestModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberRequestModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    private func perform() {
        registerCollectionViewCell(collectionView: collectionView, cell: JobberNumericRequestCollectionViewCell.self)
        registerCollectionViewCell(collectionView: collectionView, cell: JobberHourRequestCollectionViewCell.self)

        snapshot = createSnapshot()
            
        collectionView.layoutIfNeeded()
        let cellCize: CGSize = CGSize(width: UIScreen.main.bounds.width-64, height: collectionView.bounds.height)
        let collectionViewLayout = CoAnimationCollectionViewFlowLayout(itemSize: cellCize)
        collectionViewLayout.alphaFactor = 0.94
        collectionView.collectionViewLayout = collectionViewLayout

        collectionViewDataSource = UICollectionViewDiffableDataSource<Section, JobberRequestModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let isNumeric = (item.services.count > 0) && (item.services.first?.unit != nil)

            switch isNumeric {
            case false:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobberHourRequestCollectionViewCell.identifier, for: indexPath) as! JobberHourRequestCollectionViewCell
                cell.updateUI(remainingTime: Int(item.remainingTime), item: item.services.first, jobName: item.jobTitle ?? "-", distance: item.distance ?? 0.0, totalPrice: item.services.first?.price ?? 0.0, address: item.address ?? "")
                cell.buttonDelegate = self
                
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobberNumericRequestCollectionViewCell.identifier, for: indexPath) as! JobberNumericRequestCollectionViewCell
                cell.updateUI(remainingTime: Int(item.remainingTime), items: item.services, jobName: item.jobTitle ?? "-", distance: (item.distance ?? 0.0), totalPrice: (item.price ?? "0.0").toDouble()!, address: item.address ?? "-")
                cell.delegate = self
                cell.buttonDelegate = self
                
                return cell
            }
        })
        
        collectionViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func rejectJobRequest(reqID: String, indexPath: IndexPath) {
        struct SendRejectModel: Codable { let request_id: String }
        let netowrk = RestfulAPI<SendRejectModel,Generic<EMPTYMODEL>>.init(path: "/jobber/request/reject")
            .with(auth: .jobber)
            .with(method: .POST)
            .with(body: SendRejectModel(request_id: reqID))
        
        handleRequestByUI(netowrk) { [weak self] (response) in
            guard let self = self else { return }
            
            self.items.remove(at: indexPath.item)
            self.snapshot = self.createSnapshot()
            self.collectionViewDataSource.apply(self.snapshot)
        }
    }
    
    @objc override func sceneDidEnterForeground() {
        super.sceneDidEnterForeground()
        fetchResult()
    }
    
    @objc func newReceiveRemoteNotification(_ notification: Notification) {
        let userInfo = notification.userInfo
        let method = userInfo?["method"] as? String ?? ""

        if (method == "NEW") {
            if let str = userInfo?["data"] as? String {
                if let data = str.data(using: .utf8) {
                    if let jobberRequestModel = try? JSONDecoder().decode(JobberRequestModel.self, from: data) {
                        // 1. put items = (ServerData)
                        items = filterEquatable(items, [jobberRequestModel])
                        // 2. start timer and reload snapshot for new data and control the duration interval: startRejectionTimeInterval()
                        startRejectionTimeInterval()
                    }
                }
            }
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
                        if let index = self.items.firstIndex(where: { i in
                            return i.id == reqID
                        }) {
                            delegate?.userCanceledThe(items[index])
                            items.remove(at: index)
                            snapshot = self.createSnapshot()
                            collectionViewDataSource.apply(self.snapshot)
                        }
                    }
                }
            }
        }
    }
    
    // UNWIND IBACTION
    @IBAction func unwindToJobberRequestViewController(_ segue: UIStoryboardSegue) {
        //
    }
}

extension JobberRequestViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func configurationMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false // DISABLE USER INTERCATION
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            mapView.centerToLocation(location, regionRadius: 10000)
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        mapView.centerToLocation(location, regionRadius: 10000)
    }
}

extension JobberRequestViewController: JobberNumericRequestCollectionViewCellDelegate {
    func requestServiceDidSelected(cell: JobberNumericRequestCollectionViewCell, selectedServiceIndexPath: IndexPath) {
        if let indexPath = collectionView.indexPath(for: cell) { // selected collection indexPath
            items[indexPath.item].services[selectedServiceIndexPath.item].isSelected!.toggle()
            
            snapshot = createSnapshot()
            collectionViewDataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

extension JobberRequestViewController: JobberRequestCollectionViewCellButtonDelegate {
    func nextButtonTapped(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var item = items[indexPath.item]
        let selectedItem = item.services.filter({ $0.isSelected! })
        let isNumeric = (item.services.count > 0) && (item.services.first?.unit != nil)

        if selectedItem.isEmpty && isNumeric {
            let alertContent = AlertContent(title: .none, subject: "Ops!".localized(), description: "Please select at least one service!".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(warningVC.prepare(warningVC.interactor))
            return
        }
        
        let vc = JobberAcceptRequestTableViewController
            .instantiateVC(.jobber)
        item.services = isNumeric ? selectedItem:item.services
        vc.item = item
        delegate = vc
        // show JobberAcceptRequestTableViewController
        show(vc, sender: nil)
    }
    
    func rejectButtonTapped(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        // guard let indexPath
        let alertContent = AlertContent(title: .delete, subject: "Reject Job".localized(), description: "Are you sure you want to reject this job order?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        // present alertVC
        present(alertVC.prepare(alertVC.interactor))
        // yes button taped:
        alertVC.yesButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            // guard let self
            let item = self.items[indexPath.item]
            self.rejectJobRequest(reqID: item.id, indexPath: indexPath)
        }
    }
}
