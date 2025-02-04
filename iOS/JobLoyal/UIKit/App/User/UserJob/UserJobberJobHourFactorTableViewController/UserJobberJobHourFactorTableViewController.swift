//
//  UserJobberJobHourFactorTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/24/1400 AP.
//

import UIKit
import RestfulAPI
import Stripe

class UserJobberJobHourFactorTableViewController: UserTableViewController {
 
    enum Section: Hashable {
        case main
        case detail
    }
    
    enum Item: Hashable {
        case service(ServiceModel)
        case detail(UserAcceptJobModel)
    }
        
    @IBOutlet weak var sumAndComissionPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var walletPriceLabel: UILabel!
    
    public var items: [Item] = []

    private let slideDownTransitionAnimator = SlideDownTransitionAnimator()

    private var tableViewDataSource: UITableViewDiffableDataSource<Section,Item>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
    public var userAcceptJobModel: UserAcceptJobModel?
    
    private var paymentSheet: PaymentSheet?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchWallet()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Factor".localized()
        // auto dimension cell
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        // perform data source and tableView
        perform()
    }
    
    func openStrikeBankPaymentVC() {
        func checkPayment() {
            let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/user/payment/check-pay")
                .with(auth: .user)
                .with(method: .POST)
            handleRequestByUI(network, animated: false) { [weak self] _ in
                guard let self = self else { return }
                // fetch status when payment state updated in server.
                self.fetchOpenOrder()
            }
        }
        
        func openPaymentSheet(paymentIntentClientSecret: String) {
            if self.paymentSheet == nil {
                // MARK: Create a PaymentSheet instance
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "JobLoyal, Inc."
//                    configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            }
            // aysnc main thread presentation
            DispatchQueue.main.async {
                // MARK: Start the checkout process
                self.paymentSheet?.present(from: self) { [weak self] paymentResult in
                  // MARK: Handle the payment result
                  switch paymentResult {
                  case .completed:
                    print("Your order is confirmed")
                    checkPayment()
                  case .canceled:
                    print("Canceled!")
                    checkPayment()
                  case .failed(let error):
                    print("Payment failed: \n\(error.localizedDescription)")
                    let alertContent = AlertContent(title: .none, subject: "Payment Failed".localized(), description: error.localizedDescription)
                    let warningVC = WarningContentViewController
                        .instantiateVC()
                        .alert(alertContent)
                    // present warning message from stripe.
                    self?.present(warningVC.prepare(warningVC.interactor),animated: true)
                  }
                }
            }
        }
        
        let network = RestfulAPI<EMPTYMODEL,Generic<RCPaymentModel>>.init(path: "/user/payment/pay")
            .with(auth: .user)
            .with(method: .POST)
            
        handleRequestByUI(network) { [weak self] response in
            guard let self = self else { return }
            
            if response.data?.paid == true {
                self.fetchOpenOrder()
               return
            }
            if response.data?.paid == false {
                // strikebank
                guard let paymentIntentClientSecret = response.data?.client_secret
//                      let customerId = response.data?.customer,
//                      let customerEphemeralKeySecret = response.data?.ephemeral_key,
                else { return }
                openPaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret)
            }
        }
    }
    
    private func payButtonTappedAcceptCondition() {
        let alertContent = AlertContent(title: .none, subject: "Payment".localized(), description: "Do you want to pay this order?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        present(alertVC.prepare(alertVC.interactor),animated: true)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            // verify request
            self.openStrikeBankPaymentVC()
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.main, .detail])

        if let userAcceptJobModel = userAcceptJobModel {
            if let services = userAcceptJobModel.services {
                let convertedServices = services.map { Item.service($0)}
                snapshot.appendItems(convertedServices, toSection: .main)
            }
            
            snapshot.appendItems([.detail(userAcceptJobModel)], toSection: .detail)
        }
 
        return snapshot
    }
    
    private func fetchWallet() {
        struct WalletModel: Codable { let credit: Double }
        let netowrk = RestfulAPI<EMPTYMODEL,Generic<WalletModel>>.init(path: "/user/wallet")
            .with(auth: .user)
            
        handleRequestByUI(netowrk) { [weak self] (response) in
            let sumAndComissionPrice = (self?.userAcceptJobModel?.totalPay?.rounded(toPlaces: 2) ?? 0.0)
            let walletPrice = (response.data?.credit ?? 0.0)
            let totalPayPrice = sumAndComissionPrice - walletPrice
            
            self?.walletPriceLabel.text = "\(response.data?.credit.rounded(toPlaces: 2) ?? 0.0) CHF"
            self?.sumAndComissionPriceLabel.text = "\(sumAndComissionPrice.toPriceFormatter) CHF"
            self?.totalPriceLabel.text = (totalPayPrice >= 0) ? "\(totalPayPrice.toPriceFormatter) CHF":"Payment by wallet".localized()
        }
    }
    
    private func perform() {
        // Regiser xib cell (one cell created in tableView directly and one cell is a Xib):
        registerTableViewCell(tableView: tableView, cell: UserJobberJobHourTableViewCell.self)
        // create snapshot
        snapshot = createSnapshot()
        // data source
        tableViewDataSource = UITableViewDiffableDataSource<Section,Item>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .service(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberJobHourTableViewCell.identifier) as! UserJobberJobHourTableViewCell
                
                cell.updateUI(price: item.price ?? 0.0, title: item.title ?? "")
                
                return cell
            case .detail(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: JobberOrderDetailRequestTableViewCell.identifier) as! JobberOrderDetailRequestTableViewCell
                let totalTimeInterval = item.totalTimeInvertal ?? 0
                let totalTimeWorked = TimerHelper.time(totalTimeInterval*60)

                cell.updateUI(time: "\(totalTimeWorked.hour):\(totalTimeWorked.minute)", price: "\(item.totalPay ?? 0.0)", underPriceName: "Total Price".localized(), underTimeName: "Total Time".localized(), name: nil)

                return cell
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    @IBAction func payButtonTapped(_ sender: Any) {
        // temp code until update V0.2 or V0.3:
        payButtonTappedAcceptCondition()
    }
}

extension UserJobberJobHourFactorTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = snapshot.sectionIdentifiers[section]
        switch section {
        case .main:
            let titleLabel = UILabel(frame: CGRect.zero)
            
            titleLabel.font = UIFont.avenirNextMedium(size: 17)
            titleLabel.textColor = UIColor.label
            titleLabel.text = "Service - Per Hour".localized()
                    
            return titleLabel
        case .detail:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = snapshot.sectionIdentifiers[section]
        
        return (section == .main) ? 48:0
    }
}

