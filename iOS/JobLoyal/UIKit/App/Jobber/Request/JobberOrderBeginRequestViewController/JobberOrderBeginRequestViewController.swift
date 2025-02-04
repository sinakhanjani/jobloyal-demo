//
//  JobberOrderBeginRequestViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/8/1400 AP.
//

import UIKit
//import Popup
import MapKit
import RestfulAPI

class JobberOrderBeginRequestViewController: JobberViewController, PopupConfiguration {
    
    enum Section: Hashable {
        case main
        case service
        case map
    }
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var callButton: AppButton!
    @IBOutlet weak var tableView: UITableView!
    
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
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = UITableView.automaticDimension
        perform()
    }

    private func updateUI() {
        if let item = item, let phone = item.user?.phone {
            callButton.setTitle("Call " + phone, for: [.normal])
        }
        
        snapshot = createSnapshot()
        tableViewDataSource.apply(snapshot)
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JobberAccpetRequestItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberAccpetRequestItem>()
        snapshot.appendSections([.main, .service, .map])
        
        if let item = item {
            let services = item.services.map({ JobberAccpetRequestItem.service(item: $0) })
            snapshot.appendItems(services, toSection: .service)
            snapshot.appendItems([.base(item: item)], toSection: .main)
            snapshot.appendItems([.map(lat: item.latitude ?? 0.0, long: item.longitude ?? 0.0, address: item.address ?? "-")], toSection: .map)
        }

        return snapshot
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource<Section,JobberAccpetRequestItem>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .base(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberOrderDetailRequestTableViewCell.identifier) as! JobberOrderDetailRequestTableViewCell
                let underPriceName = item.timeBase ? "Per Hour".localized():"Paid".localized()
                cell.updateUI(time: item.arrivalTime?.to(date: "HH:mm") ?? "-", price: item.total, underPriceName: underPriceName, underTimeName: "Arrival Time".localized(), name: item.user?.name ?? "-")
                
                return cell
            case .service(let service): // service
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestTableViewCell.identifier) as! JobberAcceptRequestTableViewCell
                cell.updateUI(serviceName: service.title ?? "-", unitName: service.unit, price: service.price)
                
                return cell
            case let .map (lat, long, address):
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberAcceptRequestMapTableViewCell.identifier) as! JobberAcceptRequestMapTableViewCell
                let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                cell.updateUI(address: address)
                cell.configurationMap(userLocation: userLocation, regionRadius: 1000)
                
                return cell
            default: return UITableViewCell()
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func dismiss() {
        // dismiss vc and go to next step
        self.fetchOpenOrder()
    }
    
    private func arriveRequest(sender: UIButton) {
        let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/jobber/request/arrive")
            .with(auth: .jobber)
            .with(method: .POST)
        
        handleRequestByUI(network, disable: [sender]) { [weak self] (response) in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }
    }
    
    // MARK: IBACTION
    @IBAction func ArrivalButtonTapped(_ sender: Any) {
        arriveRequest(sender: sender as! UIButton)
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
    
    @IBAction func phoneButtonTapped(_ sender: Any) {
        let phoneNumber = item?.user?.phone
        phoneNumber?.makeACall()
    }
    
    deinit {
        jobberIdentifierHandler.remove(identifier: String(describing: self))
    }
}

extension JobberOrderBeginRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .main: return 128
        case .service: return UITableView.automaticDimension
        case .map: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard snapshot.sectionIdentifiers[indexPath.section] == .map else { return nil }
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in
            let lat = self.item?.latitude ?? 0.0
            let long = self.item?.longitude ?? 0.0
            let openInMap = UIAction(title: "Open In".localized()+" Maps", image: UIImage(systemName: "map.fill")!) { (action) in
                self.openMapsAppWithDirections(to: CLLocationCoordinate2D(latitude: lat, longitude: long), destinationName: "")
            }
            let openInGoogleMap = UIAction(title: "Open In".localized() + " Google Maps", image: UIImage(systemName: "map.fill")!) { (action) in
                UIApplication.shared.open(URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(lat),\(long)&directionsmode=driving")!)
            }
            let openInWaze = UIAction(title: "Open In".localized() + " Waze", image: UIImage(systemName: "map.fill")!) { (action) in
                UIApplication.shared.open(URL(string: "waze://?ll=\(lat),\(long)&navigate=yes")!)
            }
            
            var actions: [UIAction] = []
            let canOpen = UIApplication.shared.canOpenURL
            
            if canOpen(URL(string:"Maps://")!) { actions.append(openInMap) }
            if canOpen(URL(string:"comgooglemaps://")!) { actions.append(openInGoogleMap) }
            if canOpen(URL(string:"waze://")!) { actions.append(openInWaze) }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: actions)
        }
        
        return config
    }
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }
}
