//
//  MessageTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/13/1400 AP.
//

import UIKit
import RestfulAPI

class MessageTableViewController: JobberTableViewController {

    enum Section: Hashable {
        case main
    }
    
    private var tableViewDataSource: UITableViewDiffableDataSource<Section,MessageModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, MessageModel>()
    
    private let emptyMessageInboxView = EmptyMessageInboxView()
    private let footerView = TicketButtonTableFooterView(frame: CGRect(x: .zero, y: .zero, width: .zero, height: 58))

    var items:[MessageModel] = []
    var auth: Authentication = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func checkAuth() {
        auth = Authentication.user.isLogin ? .user:.jobber
    }
    
    private func updateUI() {
        title = "Tickets".localized()
        emptyMessageInboxView.ticketButton.addTarget(self, action: #selector(ticketButtonTapped(_:)), for: .touchUpInside)
        footerView.ticketButton.addTarget(self, action: #selector(ticketButtonTapped(_:)), for: .touchUpInside)
        
        fetch(animated: true)
        perform()
    }
    
    private func fetch(animated: Bool) {
        checkAuth()
        let path = auth == .jobber ? "jobber":"user"
        let network = RestfulAPI<EMPTYMODEL,Generic<MessagesModel>>.init(path: "/\(path)/messages")
            .with(auth: auth)
            
        handleRequestByUI(network, animated: animated) { [weak self] (response) in
            guard let self = self else { return }
            
            self.items = response.data?.items ?? []
            self.snapshot = self.createSnapshot()
            self.tableViewDataSource.apply(self.snapshot, animatingDifferences: true, completion: nil)
        }
    }

    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section,MessageModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,MessageModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
                
        tableView.backgroundView = items.isEmpty ? emptyMessageInboxView : nil
        tableView.tableFooterView = !items.isEmpty ? footerView : nil
        
        return snapshot
    }
    
    @objc func ticketButtonTapped(_ sender: UIButton) {
        let vc = AddMessageTableViewController.instantiateVC()
        vc.auth = auth
        vc.delegate = self
        
        show(vc, sender: nil)
    }
    
    private func perform() {
        tableViewDataSource = UITableViewDiffableDataSource<Section,MessageModel>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier) as! MessageTableViewCell
            cell.updateUI(isAnswered: item.reply == nil ? false:true, title: item.subject ?? "-", date: item.createdAt?.to(date: "YYYY-MM-dd HH:mm") ?? "-")
            
            return cell
        })
        
        tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    @IBAction func createNewTicketButtonTapped(_ sender: Any) {
        //
    }
}

extension MessageTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        let vc = AnsweredMessageTableViewController.instantiateVC()
        vc.auth = auth
        vc.item = item
        
        show(vc, sender: nil)
    }
}

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func ticketAdded() {
        fetch(animated: false)
    }
}
