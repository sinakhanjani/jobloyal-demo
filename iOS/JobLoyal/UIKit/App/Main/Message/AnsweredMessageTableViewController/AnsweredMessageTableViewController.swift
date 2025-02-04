//
//  AnsweredMessageTableViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/13/1400 AP.
//

import UIKit
import RestfulAPI

class AnsweredMessageTableViewController: JobberTableViewController {
    
    @IBOutlet weak var answeredLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var subjectQuestionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    public var item: MessageModel?
    public var auth: Authentication = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuth()
        updateUI()
    }
    
    func checkAuth() {
        auth = Authentication.user.isLogin ? .user:.jobber
    }

    private func updateUI() {
        title = "Answer".localized()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        updateLabels()
    }
    
    private func updateLabels() {
        guard let item = item else { return }
        
        answeredLabel.text = item.reply?.answer?.firstUppercased ?? "Not answered, we will answer you soon".localized()
        subjectQuestionLabel.text = item.subject?.firstUppercased
        questionLabel.text = item.itemDescription?.firstUppercased
        dateLabel.text = item.reply?.createdAt?.to(date: "YYYY-MM-dd HH:mm")
    }
}

extension AnsweredMessageTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
