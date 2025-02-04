//
//  UserJobberAcceptanceJobTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit
import RestfulAPI
import Stripe

class UserJobberAcceptanceJobTableViewController: UserTableViewController {
    // section
    enum Section: Hashable {
        case info
        case service
        case comment
    }
    // row
    enum Item: Hashable {
        case info(UserAcceptJobModel)
        case service(ServiceModel)
        case comment(CommentModel)
    }
            
    public var items: [Item] = []
    private var userAcceptJobModel: UserAcceptJobModel?
    
    private let unwindToFindJobViewControllerSegue = "unwindToFindJobViewControllerSegue"
    private let slideDownTransitionAnimator = SlideDownTransitionAnimator()

    private var tableViewDataSource: UITableViewDiffableDataSource<Section,Item>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    private let headerTableView = UserJobberAcceptanceHeaderTableView(height: 110)
    private let payFooterTableView = UserJobberAcceptancePayFooterTableView(heigh: 102)
    private let verifyFooterTableView = UserJobberAcceptanceFooterTableView(height: 128, state: .verify)
    private let callFooterTableView = UserJobberAcceptanceFooterTableView(height: 128, state: .call)
    private let doingFooterTableView = UserJobberAcceptanceDoingFooterTableView(height: 102)
    private let cancelRightBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.tintColor = .heavyRed
        barButton.title = "Cancel".localized()
        barButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.avenirNextMedium(size: 17)], for: [.normal])
        
        return barButton
    }()
    
    private var timerHelper: TimerHelper?
    
    public var status: UserJobStatus = .accepted
    public var serviceID: String?
    
    private var paymentSheet: PaymentSheet?
    private var rcPaymentModel: RCPaymentModel?
                
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // recieved notification
        NotificationCenter.default.addObserver(self, selector: #selector(userStatusChanged(_:)), name: .userStatusChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        // fetch data
        fetch(with: serviceID)
    }
    
    private func configUI() {
        func addFooterButtonEvents() {
            payFooterTableView.payButton.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
            callFooterTableView.payButton.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
            verifyFooterTableView.payButton.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
        }
        // configuration right bar button
        cancelRightBarButton.action = #selector(cancelRequestButtonTapped)
        cancelRightBarButton.target = self
        // configuration attribute
        title = "Open Order".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        // add footer button events
        addFooterButtonEvents()
        perform()
    }
    
    private func updateStateUI() {
        
        // update cancel button for status
        func updateCancelRightBarButton() {
            switch status {
            case .created,.accepted,.paid:
                navigationItem.rightBarButtonItem = cancelRightBarButton
            // user can't cancel request when status is .created,.accepted,.paid
            default:
                navigationItem.rightBarButtonItem = nil
            }
        }
        // update status function
        func updateStatusUI() {
            // nemeric update phone button:
            let buttonTitle = "Call".localized() + " \(userAcceptJobModel?.page?.phoneNumber ?? "")"
            callFooterTableView.payButton.setTitle(buttonTitle, for: .normal)
            // switch status for change UI and interaction UI elements
            switch status {
            case .created: break
            case .accepted:
                func tableHeaderCondition() -> UIView? {
                    let condition = ((timerHelper?.elapsedTimeInSecond ?? 0) <= 0)
                    return condition ? nil:headerTableView
                }
                let isTimeBase = (userAcceptJobModel?.timeBase ?? false)
                // set table header and footer
                tableView.tableFooterView = isTimeBase ? callFooterTableView:payFooterTableView
                tableView.tableHeaderView = isTimeBase ? nil:tableHeaderCondition()
                // if hour : show number && callFooterTableView
                // if numeric don't show phoneNumber && payFooterTableView
            case .paid:
                tableView.tableFooterView = callFooterTableView
                // this is for step paid in numeric and refresh data for show phone number
                if userAcceptJobModel?.page?.phoneNumber == nil {
                    fetch(with: self.serviceID)
                }
                // remove arrived time interval
                tableView.tableHeaderView = nil
            case .arrived:
                // remove arrived time interval
                self.userAcceptJobModel?.arrivalTime = nil
                self.snapshot = createSnapshot()
                self.tableViewDataSource.apply(snapshot)
                tableView.tableHeaderView = nil
            case .started:
                // show doing cell
                tableView.tableFooterView = doingFooterTableView
            case .finished:
                // show verify cell
                tableView.tableFooterView = verifyFooterTableView
                tableView.tableHeaderView = nil
            case .verified:
                // auto api show ratingViewController when we pushBack()
                tableView.tableHeaderView = nil
                pushBackController()
            }
        }
        // call internal functions
        updateCancelRightBarButton()
        updateStatusUI()
    }
    
    private func fetch(with id: String?) {
        guard let id = id else { return }
        let network = RestfulAPI<EMPTYMODEL,Generic<UserAcceptJobModel>>.init(path: "/user/request/page/\(id)")
            .with(auth: .user)
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            self.userAcceptJobModel = response.data
            if let status = response.data?.status, let userJobStatus = UserJobStatus(rawValue: status) {
                self.status = userJobStatus
            }
            self.payFooterTableView.titleLabel.text = "Total".localized() + ": " + "\( response.data?.totalPay ?? 0.0) CHF"
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot)
            self.startHeaderTableViewCancelationTimer()
            self.updateStateUI()
        }
    }
    
    private func startHeaderTableViewCancelationTimer() {
        guard !(userAcceptJobModel?.timeBase ?? false) else { return }
        let second = userAcceptJobModel?.remainingTime ?? JobloyalCongfiguration.Time.userTimePaying
        let time = TimerHelper.time(second)
        headerTableView.titleLabel.text = "We reserved jobber for".localized() + " \(time.minute):\(time.secend) " + "seconds".localized()

        timerHelper?.resetTimer()
        timerHelper = TimerHelper(elapsedTimeInSecond: second)
        timerHelper?.start(completion: { [weak self] (second,minute) in
            guard let self = self else { return }
            // active timer
            self.headerTableView.timerLabel.text = "\(minute):\(second)"
            // when timer is zero:
            if (self.timerHelper?.elapsedTimeInSecond ?? 0) <= 0 {
                self.timerHelper?.pauseTimer()
                self.headerTableView.timerLabel.text = "00:00"
                self.tableView.tableHeaderView = nil
                self.timerHelper = nil
            }
        })
    }
    
    private func verifyRequest() {
        let alertContent = AlertContent(title: .none, subject: "Verify Jobber".localized(), description: "Do you want to verify the jobber?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        present(alertVC.prepare(alertVC.interactor),animated: true)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            let netowrk = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/user/payment/verify-pay")
                .with(auth: .user)
                .with(method: .POST)
            
            self.handleRequestByUI(netowrk) { [weak self] (response) in
                guard let self = self else { return }
                self.pushBackController()
            }
        }
    }
    
    private func acceptPayButtonTappedCondition() {
        func openStripeBankPaymentVC() {
            func checkPayment() {
                let network = RestfulAPI<EMPTYMODEL,Generic<EMPTYMODEL>>.init(path: "/user/payment/check-pay")
                    .with(auth: .user)
                    .with(method: .POST)
                handleRequestByUI(network) { [weak self] _ in
                    guard let self = self else { return }
                    self.fetch(with: self.serviceID)
                }
            }
            
            func openPaymentSheet(paymentIntentClientSecret: String) {
                if paymentSheet == nil {
                    // MARK: Create a PaymentSheet instance
                    var configuration = PaymentSheet.Configuration()
                    configuration.merchantDisplayName = "JobLoyal, Inc."
//                    configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                    paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
                }
                // MARK: Start the checkout process
                paymentSheet?.present(from: self) { [weak self] paymentResult in
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

                    self?.present(warningVC.prepare(warningVC.interactor),animated: true)
                  }
                }
            }
            
            let network = RestfulAPI<EMPTYMODEL,Generic<RCPaymentModel>>.init(path: "/user/payment/pay")
                .with(auth: .user)
                .with(method: .POST)
                
            handleRequestByUI(network) { [weak self] response in
                guard let self = self else { return }
                if response.data?.paid == true {
                    self.fetch(with: self.serviceID)
                   return
                }
                if response.data?.paid == false {
                    self.rcPaymentModel = response.data
                    // stripebank
                    guard let paymentIntentClientSecret = response.data?.client_secret
//                          let customerId = response.data?.customer,
//                          let customerEphemeralKeySecret = response.data?.ephemeral_key,
                    else { return }
                    
                    openPaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret)
                }
            }
        }
        
        let alertContent = AlertContent(title: .none, subject: "Payment".localized(), description: "Do you want to pay this order?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        present(alertVC.prepare(alertVC.interactor),animated: true)
        
        alertVC.yesButtonTappedHandler = {
            openStripeBankPaymentVC()
        }
    }
    
    private func pushBackController() {
        fetchOpenOrder()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.info, .service])
        if let item = self.userAcceptJobModel {
            snapshot.appendItems([.info(item)], toSection: .info)
            if let services = item.services {
                let convertedServices = services.map { Item.service($0) }
                snapshot.appendItems(convertedServices, toSection: .service)
            }
            if let comments = item.comments, !comments.isEmpty {
                snapshot.appendSections([.comment])
                let convertedComments = comments.map { Item.comment($0) }
                snapshot.appendItems(convertedComments, toSection: .comment)
            }
        }

        return snapshot
    }
    
    private func perform() {
        // Regiser cell:
        registerTableViewCell(tableView: tableView, cell: UserJobberAcceptanceJobInfoTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: UserJobberAcceptanceJobReservedServiceTableViewCell.self)
        registerTableViewCell(tableView: tableView, cell: CommentTableViewCell.self)
        
        tableViewDataSource = UITableViewDiffableDataSource<Section,Item>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .info(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberAcceptanceJobInfoTableViewCell.identifier) as! UserJobberAcceptanceJobInfoTableViewCell
                let page = item.page
                
                cell.updateUI(jobberName: page?.name?.capitalized ?? "", jobberID: page?.identifier ?? "", workNumber: page?.workCount ?? 0, commentNumber: page?.totalComments ?? 0, receiveTime: item.arrivalTime?.to(date: "HH:mm") ?? "Arrived".localized(), imageURL: page?.avatar ?? "", rate: Double(page?.rate ?? "0.0")!)
                
                return cell
            case .service(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: UserJobberAcceptanceJobReservedServiceTableViewCell.identifier) as! UserJobberAcceptanceJobReservedServiceTableViewCell
                let unitValue = (item.unit != nil) ? "\((item.count ?? 0))":"\((item.price ?? 0.0).toPriceFormatter) CHF"
                var tags: [UserJobberAcceptanceJobReservedServiceTableViewCell.Tag] = []
                
                tags.append(item.accepted ? .accepted:.rejected)
                if (item.isPaid ?? false) {
                    tags.append(.paid)
                }
                
                cell.updateUI(serviceName: item.title ?? "", price: item.price ?? 0.0, totalPrice: item.totalPrice ?? 0.0, unitName: item.unit?.firstUppercased, unitValue: unitValue, tags: tags)

                return cell
            case .comment(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier) as! CommentTableViewCell
                cell.updateUI(subject: item.service_title ?? "", description: item.comment ?? "", rating: Double(item.rate ?? "0.0")!)
                
                return cell
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    @objc func userStatusChanged(_ notificaiton: Notification) {
        guard let item = notificaiton.userInfo?["user.item"] as? UserAcceptJobStatusModel else { return }
        if let status = item.status, let userJobStatus = UserJobStatus(rawValue: status) {
            self.status = userJobStatus
            // update cell state every notification comes
            updateStateUI()
        }
    }

    @objc func moreCommentButtonTapped() {
        let vc = CommentTableViewController.instantiateVC()
        vc.jobID = userAcceptJobModel?.jobID
        vc.jobberID = userAcceptJobModel?.page?.id
        
        show(vc, sender: nil)
    }
    
    @objc func footerButtonTapped() {
        let isNumeric = !(self.userAcceptJobModel?.timeBase ?? false)
        let phoneNumber = userAcceptJobModel?.page?.phoneNumber
        switch status {
        case .paid:
            phoneNumber?.makeACall()
        case .accepted:
            isNumeric ? acceptPayButtonTappedCondition():phoneNumber?.makeACall()
        case .finished:
            func presentJobberHourFactorVC() {
                let vc = UserJobberJobHourFactorTableViewController.instantiateVC(.user)
                vc.userAcceptJobModel = userAcceptJobModel
                
                show(vc, sender: nil)
            }
            
            isNumeric ? verifyRequest():presentJobberHourFactorVC()
        default: break
        }
    }
    
    @objc func cancelRequestButtonTapped() {
        let alertContent = AlertContent(title: .none, subject: "Cancel Request".localized(), description: "Do you want to cancel this request?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)
        
        present(alertVC.prepare(interactor),animated: true)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            guard let self = self else { return }
            self.cancelOrderRequest { [weak self] in
                self?.pushBackController()
            }
        }
    }
}

extension UserJobberAcceptanceJobTableViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionItem = snapshot.sectionIdentifiers[section]
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        titleLabel.textColor = UIColor.label
        
        switch  sectionItem {
        case .info:
            titleLabel.text = ""
        case .service:
            titleLabel.text = "Reserved Services".localized()
        case .comment:
            titleLabel.text = "Comments".localized()
        }
                
        return titleLabel
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionItem = snapshot.sectionIdentifiers[section]
        guard sectionItem == .comment else { return nil }
        let moreButton = UIButton()
        
        moreButton.frame = CGRect(x: .zero, y: .zero, width: .zero, height: 44)
        moreButton.setTitle("More Comments".localized(), for: .normal)
        moreButton.titleLabel?.font = UIFont.avenirNextMedium(size: 17)
        moreButton.setTitleColor(.heavyBlue, for: .normal)
        moreButton.titleLabel?.textAlignment = .center
        moreButton.addTarget(self, action: #selector(moreCommentButtonTapped), for: .touchUpInside)
        
        return moreButton
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = self.snapshot.sectionIdentifiers[section]
        if section == .comment { return 48 } else { return 0 }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
