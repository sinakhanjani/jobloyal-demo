//
//  UserJobberJobNumericTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/20/1400 AP.
//

import UIKit
import CoreLocation
import RestfulAPI

class UserJobberJobNumericTableViewController: UserTableViewController {

    enum Section: Hashable {
        case main
    }
        
    @IBOutlet weak var sumAndComissionPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var walletPriceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    public var items: [ServiceJobModel] = []
    public var jobberListModel: RCJobberListModel?
    public var coordinate: CLLocationCoordinate2D?
    private var walletPrice: Double?
    
    private let slideDownTransitionAnimator = SlideDownTransitionAnimator()

    private var tableViewDataSource: UITableViewDiffableDataSource<Section,ServiceJobModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, ServiceJobModel>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private func configUI() {
        title = "Jobber Services".localized()
        // configuration cell of tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        // config other UI elements.
        fetchWallet()
        updateUI()
        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,ServiceJobModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,ServiceJobModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        
        return snapshot
    }
    
    private func perform() {
        // Regiser cell:
        registerTableViewCell(tableView: tableView, cell: UserJobberJobNumericTableViewCell.self)
        
        snapshot = createSnapshot()
        
        tableViewDataSource = UITableViewDiffableDataSource<Section,ServiceJobModel>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberJobNumericTableViewCell.identifier) as! UserJobberJobNumericTableViewCell
            cell.updateUI(serviceTitle: item.title ?? "", unitPrice: item.price ?? 0.0, totalPrice: item.totalPrice ?? 0.0, unitTitle: item.unit)
            cell.delegate = self
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    
    private func fetchWallet() {
        struct WalletModel: Codable { let credit: Double }
        let netowrk = RestfulAPI<EMPTYMODEL,Generic<WalletModel>>.init(path: "/user/wallet")
            .with(auth: .user)
            
        handleRequestByUI(netowrk, animated: false) { [weak self] (response) in
            self?.walletPrice = response.data?.credit
            self?.walletPriceLabel.text = "\((response.data?.credit ?? 0.0).toPriceFormatter) CHF"
        }
    }
    
    private func sendJobRequest() {
        guard let jobberID = jobberListModel?.jobberID else { return }
        
        let isCountNil = items.contains(where: { (item) -> Bool in
            item.count == nil || item.count == 0
        })
        if isCountNil {
            let alertContent = AlertContent(title: .none, subject: "Empty Unit".localized(), description: "Please enter the values ​​of all fields".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)

            present(warningVC.prepare(warningVC.interactor),animated: true)
            return
        }
        
        let sendServicesModel = items.map { item -> SendServiceRequestModel in
            return SendServiceRequestModel.init(id: item.id!, count: Int(item.count!))
        }
        let body = SendUserjobRequestModel(latitude: coordinate?.latitude ?? 0.0, longitude: coordinate?.longitude ?? 0.0, jobberID: jobberID, services: sendServicesModel)
        let network = RestfulAPI<SendUserjobRequestModel,Generic<RCUserjobRequestModel>>.init(path: "/user/request/add")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        view.endEditing(true)

        handleRequestByUI(network, disable: [sendButton]) { [weak self] (response) in
            guard let self = self else { return }
            self.fetchOpenOrder()
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func updateUI() {
        func calculateTotalPrice() -> (totalPayPrice: Double, totalPriceAndCommission: Double) {
            let totalPriceAndCommission = self.items.reduce(0.0) { (oldValue, service) -> Double in
                let totalServicePrice = service.totalPrice ?? 0.0
                let priceWithCommission: Double = (1+((service.commission ?? 0.0)/100)) * totalServicePrice
                
                return oldValue + priceWithCommission
            }.rounded(toPlaces: 2)
            // user total payment
            var totalPayPrice = totalPriceAndCommission - (walletPrice ?? 0.0).rounded(toPlaces: 2)
            // happen when wallet is bigger than order.
            if totalPayPrice <= 0 { totalPayPrice = 0.0 }
            
            return (totalPayPrice, totalPriceAndCommission)
        }
        
        if calculateTotalPrice().totalPriceAndCommission > 0.0 {
            totalPriceLabel.text = "\(calculateTotalPrice().totalPriceAndCommission.rounded(toPlaces: 2).toPriceFormatter) CHF"
        } else {
            totalPriceLabel.text = "Payment by wallet".localized()
        }
        
        sumAndComissionPriceLabel.text = "\(calculateTotalPrice().totalPayPrice.toPriceFormatter) CHF"
        walletPriceLabel.text = "\((walletPrice ?? 0.0).rounded(toPlaces: 2).toPriceFormatter) CHF"
    }
    
    @IBAction func nextAndRequestButtonTapped(_ sender: Any) {
        sendJobRequest()
    }
}

extension UserJobberJobNumericTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        titleLabel.textColor = UIColor.label
        titleLabel.text = "Services".localized()
                
        return titleLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let userJobberJobNumericOrHourFooterTableViewSection = UserJobberJobNumericOrHourFooterTableViewSection()
        userJobberJobNumericOrHourFooterTableViewSection.descriptionLabel.text = "In this step you should choose amount of each services that have an unit like a painting taht have meter unit".localized()

        return userJobberJobNumericOrHourFooterTableViewSection
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        140
    }
}

extension UserJobberJobNumericTableViewController: UserJobberJobNumericTableViewCellDelegate {
    func unitTextFieldEditingChanged(sender: UITextField, cell: UserJobberJobNumericTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let item = self.items[indexPath.item]
            guard let count = Int(sender.text!) else {
                self.items[indexPath.item].totalPrice = 0.0
                self.items[indexPath.item].count = 0
                cell.totalPriceLabel.text = "\(0.0.toPriceFormatter) CHF"
                
                updateUI()
                
                return
            }
            if let pricePerUnit = item.price {
                let totalPrice: Double = Double(count) * pricePerUnit.rounded(toPlaces: 2)
                self.items[indexPath.item].totalPrice = totalPrice.rounded(toPlaces: 2)
                self.items[indexPath.item].count = count
                // reload snapshot
                cell.totalPriceLabel.text = "\(totalPrice.rounded(toPlaces: 2).toPriceFormatter) CHF"
                updateUI()
            }
        }
    }
}
