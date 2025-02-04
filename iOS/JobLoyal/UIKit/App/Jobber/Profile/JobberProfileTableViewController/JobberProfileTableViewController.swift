//
//  JobberProfileTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/10/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

class JobberProfileTableViewController: JobberTableViewController {
  
    enum Section: Hashable {
        case main
        case creditOrAuth
        case menu
    }
        
    var items: [JobberMenuModel] = [JobberMenuModel(menuItem: .Payment, image: UIImage(systemName: "wallet.pass")!),
                                    JobberMenuModel(menuItem: .Notification, image: UIImage(systemName: "paperplane")!),
                                    JobberMenuModel(menuItem: .Turnover, image: UIImage(systemName: "arrow.turn.up.forward.iphone")!),
                                    JobberMenuModel(menuItem: .Message, image: UIImage(systemName: "message")!),
//                                    JobberMenuModel(menuItem: .Insurance, image: UIImage(systemName: "aqi.medium")!),
                              JobberMenuModel(menuItem: .TermAndConditions, image: UIImage(systemName: "book")!),
                              JobberMenuModel(menuItem: .AboutUs, image: UIImage(systemName: "person.3")!),
//                              JobberMenuModel(menuItem: .ContactUs, image: UIImage(systemName: "info.circle")!),
                              JobberMenuModel(menuItem: .Logout, image: UIImage(systemName: "arrow.turn.down.right")!)
    ]
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,JobberProfileMenuModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberProfileMenuModel>()
    
    private var jobberProfile: JobberProfileModel?
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchJobberProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        updateImagePicker(.photoLibrary)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        perform()
    }
    
    private func authorization(status code: Int?) -> Authorize {
        guard let code = jobberProfile?.authority?.code else { return .noAuthorize }
        
        switch code {
        case ...(-1): return .nonAcceptedPhoto
        case 0: return .noAuthorize
        case 1: return .pendingAuthorize
        case 2: return .completeProfile
        case 3: return .doneAuthorize(jobberProfile?.credit ?? 0.0)
        default: return .noAuthorize
        }
    }
    
    private func fetchJobberProfile() {
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberProfileModel>>.init(path: "/jobber/profile")
            .with(auth: .jobber)
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            
            if let item = response.data {
                self.jobberProfile = item
                self.snapshot = self.createSnapshot()
                self.tableViewDataSource.apply(self.snapshot)
                
                NotificationCenter.default.post(name: .jobberProfileChanged, object: nil, userInfo: ["jobber.profile":item])
            }
        }
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,JobberProfileMenuModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberProfileMenuModel>()
        snapshot.appendSections([.main, .creditOrAuth, .menu])
        
        if let jobberProfile = jobberProfile {
            let jobberInfoMenu = JobberInfoMenuModel(jobberProfileModel: jobberProfile)
            snapshot.appendItems([.main(jobberInfoMenu)], toSection: .main)
        }
        // must add credit or authorize *
        // server tell us:
        if let authCode = jobberProfile?.authority?.code {
            let authorize = authorization(status: authCode)
            snapshot.appendItems([.creditOrAuth(item: authorize)], toSection: .creditOrAuth)
            if case .doneAuthorize(_) = authorize {
                let editMenu = JobberMenuModel(menuItem: .EditProfile, image: UIImage(systemName: "person")!)
                if !items.contains(editMenu) { items.insert(editMenu, at: 3) }
            }
        }
        
        let profileMenuModels = items.map { JobberProfileMenuModel.menu(item: $0) }
        snapshot.appendItems(profileMenuModels, toSection: .menu)
        
        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()
        
        tableViewDataSource = UITableViewDiffableDataSource<Section,JobberProfileMenuModel>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .main(let item): // profile cell
                let  cell = tableView.dequeueReusableCell(withIdentifier: JobberProfileTableViewCell.identifier) as! JobberProfileTableViewCell
                let name = (item.name ?? "").firstUppercased
                let family = (item.family ?? "").firstUppercased
                
                cell.delegate = self
                cell.updateUI (name: "\(name) \(family)", id: item.identifier ?? "", phone: item.phoneNumber ?? "", imageURL: item.avatar)
                
                return cell
            case .creditOrAuth(let authorize):
                let cell: UITableViewCell
                
                switch authorize {
                case .noAuthorize:
                    cell = tableView.dequeueReusableCell(withIdentifier: JobberProfileAuthorizeTableViewCell.identifier) as! JobberProfileAuthorizeTableViewCell
                    (cell as! JobberProfileAuthorizeTableViewCell).updateUI(description: "You not Authorized yet, Click Here to Authorize you".localized(), authorize: .noAuthorize)
                case .pendingAuthorize: // show authorize cell
                    cell = tableView.dequeueReusableCell(withIdentifier: JobberProfileAuthorizeTableViewCell.identifier) as! JobberProfileAuthorizeTableViewCell
                    (cell as! JobberProfileAuthorizeTableViewCell).updateUI(description: "Please wait until verify your documents".localized(), authorize: .pendingAuthorize)
                case .completeProfile: // show authorize cell
                    cell = tableView.dequeueReusableCell(withIdentifier: JobberProfileAuthorizeTableViewCell.identifier) as! JobberProfileAuthorizeTableViewCell
                    (cell as! JobberProfileAuthorizeTableViewCell).updateUI(description: "Complete your profile".localized(), authorize: .pendingAuthorize)
                case .doneAuthorize(let price): // show credit cell
                    let doneCell = tableView.dequeueReusableCell(withIdentifier: JobberProfileCreditTableViewCell.identifier) as! JobberProfileCreditTableViewCell
                    
                    doneCell.updateUI(price: price)
                    cell = doneCell
                case .nonAcceptedPhoto:
                    cell = tableView.dequeueReusableCell(withIdentifier: JobberProfileAuthorizeTableViewCell.identifier) as! JobberProfileAuthorizeTableViewCell
                    (cell as! JobberProfileAuthorizeTableViewCell).updateUI(description:"Your upload photo was not approved, please try again".localized(), authorize: .noAuthorize)
                    
                    cell.backgroundColor = .heavyRed
                }
                
                return cell
            case .menu(let menu):
                let  cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)
                // configuration cell attribute
                cell?.imageView?.image = menu.image
                cell?.textLabel?.text = menu.menuItem.value
                cell?.accessoryType = .disclosureIndicator
                
                return cell
            }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func jobberLogoutRequest() {
        guard let uuid = UIApplication.deviceID else { return }
        struct SendLogoutModel: Codable { let device_id: String }
        
        let network = RestfulAPI<SendLogoutModel,Generic<EMPTYMODEL>>.init(path: "/jobber/device/logout")
            .with(method: .POST)
            .with(auth: .jobber)
            .with(body: SendLogoutModel(device_id: uuid))
        
        handleRequestByUI(network) { (response) in
            let nav = UINavigationController
                .instantiateVC(withId: "RegisterInitializerNavigation")
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            // logout from server token
            Auth.shared.jobber.logout()
            // remove reminder notification
            JobloyalCongfiguration.Notification.dailyUpdateJob.unschedule()
            JobloyalCongfiguration.Notification.dailyUpdateJobStatus = true
        }
    }
    
    func jobberLogout() {
        let alertContent = AlertContent(title: .none, subject: "Logout".localized(), description: "Are you sure to want logout from jobloyal?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)

        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.jobberLogoutRequest()
        }
        
        present(alertVC.prepare(alertVC.interactor), animated: true)
    }
}

extension JobberProfileTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .main: return 130
        case .creditOrAuth: return UITableView.automaticDimension
        case .menu: return 52
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .main:
            break
        case .creditOrAuth:
            let creditOrAuth = snapshot.itemIdentifiers(inSection: .creditOrAuth).first!
            switch creditOrAuth {
            case .creditOrAuth(let item):
                switch item {
                case .noAuthorize, .nonAcceptedPhoto:
                    let vc = JobberAuthenticateTableViewController.instantiateVC(.jobber)
                    vc.jobberProfile = jobberProfile
                    show(vc, sender: nil)
                case .completeProfile:
                    let vc = JobberCompleteProfileTableViewController.instantiateVC(.jobber)
                    vc.jobberProfile = jobberProfile
                    show(vc, sender: nil)
                default: break
                }
            default: break
            }
        case .menu: // section menu
            let menuItem = items[indexPath.item].menuItem
            var vc: UIViewController!
            switch menuItem {
            case .Payment:
                let vc = JobberPaymentTableViewController.instantiateVC(.jobber)
                vc.statics = jobberProfile?.statics
                show(vc, sender: nil)
            case .Notification:
                let vc = JobberNotificationTableViewController.instantiateVC(.jobber)
                vc.statics = jobberProfile?.statics
                show(vc, sender: nil)
            case .EditProfile:
                let vc = JobberEditProfileTableViewController.instantiateVC(.jobber)
                vc.jobberProfile = jobberProfile
                show(vc, sender: nil)
            case .Turnover:
                let vc = JobberTurnoverTableViewController.instantiateVC(.jobber)
                show(vc, sender: nil)
            case .Message:
                let vc = MessageTableViewController.instantiateVC()
                vc.auth = .jobber
                show(vc, sender: nil)
            case .Insurance:
                show(JobberInsuranceViewController
                        .instantiateVC(.jobber), sender: nil)
            case .TermAndConditions:
                vc = JobberTermAndConditionViewController.instantiateVC(.jobber)
                show(vc, sender: nil)
            case .AboutUs:
                vc = JobberAboutUsViewController.instantiateVC(.jobber)
                show(vc, sender: nil)
            case .ContactUs:
                vc = JobberContactUsViewController.instantiateVC(.jobber)
                show(vc, sender: nil)
            case .Logout: jobberLogout()
            }
        }
    }
}

extension JobberProfileTableViewController: JobberProfileTableViewCellDelegate, ImportPhotoInjection {
    func imageGestureTapped() {
        // if need to update image when user touch it use this event function
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickupImage = info[.originalImage] as? UIImage else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(item: .zero, section: .zero)) as? JobberProfileTableViewCell else { return }
    
        cell.updateImage(image: pickupImage)
        picker.dismiss(animated: true, completion: nil)
    }
}
