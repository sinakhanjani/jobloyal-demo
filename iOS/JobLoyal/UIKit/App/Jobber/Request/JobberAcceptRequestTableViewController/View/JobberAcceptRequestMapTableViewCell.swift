//
//  JobberAcceptRequestMapTableViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit
import MapKit

class JobberAcceptRequestMapTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!

    private let locationManager = CLLocationManager()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateUI(address: String) {
        self.addressLabel.text = address
    }
}

extension JobberAcceptRequestMapTableViewCell: MKMapViewDelegate, CLLocationManagerDelegate {
    public func configurationMap(userLocation: CLLocationCoordinate2D, regionRadius: CLLocationDistance) {
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        mapView.centerToLocation(location, regionRadius: 10000)
    }
}
