//
//  UserProfileTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/23/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

class UserProfileTableViewController: UserTableViewController {
    
    enum Section: Hashable {
        case main
        case wallet
        case menu
    }
    
    var items: [UserMenuModel] = [
                                  UserMenuModel(menuItem: .ReservedServices, image: UIImage(systemName: "doc.text")!),
                                  UserMenuModel(menuItem: .CanceledServices, image: UIImage(systemName: "pip.exit")!),
//                                    UserMenuModel(menuItem: .Insurance, image: UIImage(systemName: "aqi.medium")!),
//                                    UserMenuModel(menuItem: .TrustAndSecurity, image: UIImage(systemName: "lock.shield.fill")!),
                                  UserMenuModel(menuItem: .Message, image: UIImage(systemName: "message")!),
//                                  UserMenuModel(menuItem: .Turnover, image: UIImage(systemName: "arrow.turn.up.forward.iphone")!),
                                  UserMenuModel(menuItem: .TermAndConditions, image: UIImage(systemName: "book")!),
                                  UserMenuModel(menuItem: .AboutUs, image: UIImage(systemName: "person.3")!),
//                                  UserMenuModel(menuItem: .ContactUs, image: UIImage(systemName: "info.circle")!),
                                  UserMenuModel(menuItem: .Logout, image: UIImage(systemName: "arrow.turn.down.right")!),
    ]

    private var tableViewDataSource: UITableViewDiffableDataSource<Section,UserProfileMenuModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, UserProfileMenuModel>()
    
    private var item: UserProfileModel?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProfile()
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        title = "Profile".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
      
        perform()
    }
    
    private func fetchProfile() {
        let network = RestfulAPI<EMPTYMODEL,Generic<UserProfileModel>>.init(path: "/user/profile")
            .with(auth: .user)
        
        handleRequestByUI(network, animated: false) { [weak self] (response) in
            guard let self = self else { return }
            
            if let item = response.data {
                self.item = response.data
                self.snapshot = self.createSnapshot()
                self.tableViewDataSource.apply(self.snapshot)
                
                NotificationCenter.default.post(name: .userProfileChanged, object: nil, userInfo: ["user.profile":item])
            }
        }
    }
      
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,UserProfileMenuModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,UserProfileMenuModel>()
        snapshot.appendSections([.main, .wallet, .menu])
        
        if let item = item {
            let userInfoMenuModel = UserInfoMenuModel(userProfileModel: item)
            snapshot.appendItems([.main(userInfoMenuModel)], toSection: .main)
            snapshot.appendItems([.wallet(item.credit ?? 0.0)], toSection: .wallet)
        }
        
        if let _ = item {
            let editMenu = UserMenuModel(menuItem: .ChangeInfo, image: UIImage(systemName: "square.and.pencil")!)
            if items[0].menuItem != .ChangeInfo {
                items.insert(editMenu, at: 0)
            }
        }
        
        let profileMenuModels = items.map { UserProfileMenuModel.menu(item: $0) }
        snapshot.appendItems(profileMenuModels, toSection: .menu)
        
        return snapshot
    }
      
    private func perform() {
        snapshot = createSnapshot()
        tableViewDataSource = UITableViewDiffableDataSource<Section,UserProfileMenuModel>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            switch item {
            case .main(let item): // profile cell
            let  cell = tableView.dequeueReusableCell(withIdentifier: UserProfileTableViewCell.identifier) as! UserProfileTableViewCell
            if let name = item.name, let family = item.family {
                cell.updateUI(userName: "\(name) \(family)", userPhone: item.phoneNumber ?? "-")
            }
              
              return cell
          case .wallet(let item):
            let cell = tableView.dequeueReusableCell(withIdentifier: JobberProfileCreditTableViewCell.identifier) as! JobberProfileCreditTableViewCell
            cell.updateUI(price: item)
              
              return cell
          case .menu(let item):
              let  cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier)
              cell?.imageView?.image = item.image
              cell?.textLabel?.text = item.menuItem.value
              cell?.accessoryType = .disclosureIndicator
              
              return cell
          }
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func jobberLogoutRequest() {
        guard let uuid = UIApplication.deviceID else { return }
        struct SendLogoutModel: Codable { let device_id: String }
        
        let network = RestfulAPI<SendLogoutModel,Generic<EMPTYMODEL>>.init(path: "/user/device/logout")
            .with(method: .POST)
            .with(auth: .user)
            .with(body: SendLogoutModel(device_id: uuid))
        
        handleRequestByUI(network) { (response) in
            Auth.shared.user.logout()
            let nav = UINavigationController
                .instantiateVC(withId: "RegisterInitializerNavigation")
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
      
    private func userLogout() {
        let alertContent = AlertContent(title: .none, subject: "Logout".localized(), description: "Do you want to logout?".localized())
        let alertVC = AlertContentViewController
            .instantiateVC()
            .alert(alertContent)

        alertVC.yesButtonTappedHandler = { [weak self] in
            self?.jobberLogoutRequest()
        }
        
        present(alertVC.prepare(alertVC.interactor), animated: true)
    }
}

extension UserProfileTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .main: return 92
        default: return 52
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch snapshot.sectionIdentifiers[indexPath.section] {
        case .main:
            break
        case .wallet:
            let alertContent = AlertContent(title: .wallet, subject: "", description: "The amount of your wallet will be used in next resevered services".localized())
            let warningVC = WarningContentViewController
                .instantiateVC()
                .alert(alertContent)
            
            present(warningVC.prepare(warningVC.interactor),animated: true)
        case .menu:
            let menuItem = items[indexPath.item].menuItem
            var vc: UIViewController!
            switch menuItem {
            case .ReservedServices:
                let vc = UserReservedServiceTableViewController.instantiateVC(.user)
                show(vc, sender: nil)
            case .CanceledServices:
                let vc = UserCanceledServiceTableViewController.instantiateVC(.user)
                show(vc, sender: nil)
            case .ChangeInfo:
                let vc = UserEditProfileTableViewController.instantiateVC(.user)
                vc.item = item

                show(vc, sender: nil)
            case .TrustAndSecurity:
                break
            case .Turnover:
                let vc = UserTurnoverTableViewController.instantiateVC(.user)
                show(vc, sender: nil)
            case .Message:
                let vc = MessageTableViewController.instantiateVC()
                vc.auth = .user
                show(vc, sender: nil)
            case .Insurance:
                break
            case .TermAndConditions:
                vc = UserTermAndConditionViewController.instantiateVC(.user)
                show(vc, sender: nil)
            case .AboutUs:
                vc = UserAboutUsViewController.instantiateVC(.user)
                show(vc, sender: nil)
            case .ContactUs:
                vc = UserContactUsViewController.instantiateVC(.user)
                show(vc, sender: nil)
            case .Logout: userLogout()
            }
        }
    }
}
