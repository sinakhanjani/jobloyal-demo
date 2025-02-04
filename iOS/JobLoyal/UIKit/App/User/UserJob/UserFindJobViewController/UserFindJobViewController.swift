//
//  UserFindJobViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/17/1400 AP.
//

import UIKit
import MapKit
import RestfulAPI

class UserFindJobViewController: UserViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findJobButton: UIButton!

    private let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirNextBold(size: 34), NSAttributedString.Key.foregroundColor: UIColor.label]
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        findJobButton.alpha = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    private func updateUI() {
        configurationMap()
        fetchOpenOrder()
        fetchOpenOrderEvery(JobloyalCongfiguration.Time.fetchOrderDuration)
        // access jobber for send notification
        (UIApplication.shared.delegate as! AppDelegate).requestForNotificationPrivacy()
    }
    
    @IBAction func unwindToUserFindJobViewController(_ segue: UIStoryboardSegue, sender: Any) {
        if let userJobCategoryViewController = segue.source as? UserJobCategoryViewController {
            UIView.animate(withDuration: 0.7) {
                self.findJobButton.alpha = 1.0
            }
            guard checkAccessGPS(locationManager: locationManager) else { return }
            // instantiate jobberListVC
            let item = userJobCategoryViewController.selectedItem
            let vc = UserJobberListTableViewController.instantiateVC(.user)
            // insert item in
            vc.coordinate = locationManager.location?.coordinate
            vc.userJobCategoryItem = item
            DispatchQueue.main.async { self.show(vc, sender: nil) }
        }
        
        if let _ = segue.source as? UserFindJobCategoryViewController {
            UIView.animate(withDuration: 0.7) {
                self.findJobButton.alpha = 1.0
            }
        }
    }

    @IBAction func findMyJobButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            (sender as! UIButton).alpha = 0.0
        }

        let vc = UserFindJobCategoryViewController
            .instantiateVC(.user)
            .prepare(interactor)
        
        present(vc)
    }
    
    @IBAction func profileMenuButtonTapped() {
        let vc = UserProfileTableViewController.instantiateVC(.user)
        show(vc, sender: nil)
    }
}

extension UserFindJobViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func configurationMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false // DISABLE USER INTERCATION
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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
