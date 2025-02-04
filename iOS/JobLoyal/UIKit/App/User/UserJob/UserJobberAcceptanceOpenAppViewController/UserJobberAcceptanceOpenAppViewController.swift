//
//  UserJobberAcceptanceOpenAppViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/22/1400 AP.
//

import UIKit
import RestfulAPI
import MapKit

class UserJobberAcceptanceOpenAppViewController: UserViewController {

    @IBOutlet weak var jobberNameLAbel: UILabel!
    @IBOutlet weak var jobberStateButton: UIButton!
    @IBOutlet weak var serviceNumberLabel: UILabel!
    @IBOutlet weak var totalPayLabel: UILabel!
    @IBOutlet weak var jobberImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!

    private let locationManager = CLLocationManager()
    
    public var item: UserAcceptJobStatusModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurationNavigationLargeTitle()
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    private func configUI() {
        title = "JOBLOYAL"
        
        configurationMap()
        presentAcceptanceJobTableViewController()
    }
    
    private func updateUI() {
        // update UI Interface and self.status
        // update elements
        guard let item = item else { return }
        
        if let name = item.jobber?.name, let family = item.jobber?.family {
            jobberNameLAbel.text = "\(name.firstUppercased) \(family.firstUppercased)"
        }
        
        if let status = item.status, let userJobStatus = UserJobStatus(rawValue: status) {
            jobberStateButton.setTitle(userJobStatus.value.firstUppercased, for: .normal)
        }
        
        jobberStateButton.isUserInteractionEnabled = false
        serviceNumberLabel.text = "\(item.serviceCount ?? "0") " + "Services".localized()
        totalPayLabel.text = "\(item.totalPay ?? 0.0) CHF"
        jobberImageView.loadImage(from: item.jobber?.avatar)
    }
    
    private func configurationNavigationLargeTitle() {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirNextBold(size: 34), NSAttributedString.Key.foregroundColor: UIColor.label]
        NotificationCenter.default.addObserver(self, selector: #selector(userStatusChanged(_:)), name: .userStatusChanged, object: nil)
    }
    
    func presentAcceptanceJobTableViewController() {
        let vc = UserJobberAcceptanceJobTableViewController.instantiateVC(.user)
        // send current status to next VC
        if let status = item?.status, let userJobStatus = UserJobStatus(rawValue: status) {
            vc.status = userJobStatus
        }
        // send serviceID to next VC
        vc.serviceID = item?.requestID
        // show view controller
        DispatchQueue.main.async {
            self.show(vc, sender: nil)
        }
    }
    
    @objc func userStatusChanged(_ notificaiton: Notification) {
        guard let item = notificaiton.userInfo?["user.item"] as? UserAcceptJobStatusModel else { return }
        if let status = item.status, let userJobStatus = UserJobStatus(rawValue: status) {
            jobberStateButton.setTitle(userJobStatus.value.firstUppercased, for: .normal)
        }
    }

    @IBAction func gestureTapped(_ sender: Any) {
        presentAcceptanceJobTableViewController()
    }
    
    @IBAction func profileMenuButtonTapped(_ sender: Any) {
        let vc = UserProfileTableViewController.instantiateVC(.user)
        show(vc, sender: nil)
    }

    deinit {
        jobberIdentifierHandler.remove(identifier: String(describing: self))
    }
}

extension UserJobberAcceptanceOpenAppViewController: MKMapViewDelegate, CLLocationManagerDelegate {
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
