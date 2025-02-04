//
//  UserFindJobCategoryViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/17/1400 AP.
//

import UIKit
//import Popup
import RestfulAPI

protocol UserFindJobCategoryViewControllerDelegate: AnyObject {
    var isExpanded: Bool { get set }
    
    func searchTextFieldEditingChanged(_ sender: UITextField)
    func handleFetchItems(results: [UserJobCategoryItem])
}

class UserFindJobCategoryViewController: UserViewController, PopupConfiguration {
    
    @IBOutlet weak var findJobViewbHeightConstraint: NSLayoutConstraint! // min:160, max:644
    @IBOutlet weak var searchTextField: InsetTextField!
    
    private let toUserJoberCategoryViewController = "toUserJoberCategoryViewControllerSegue"
    private let unwindToUserFindJobViewController = "toUserFindJobViewControllerSegue"
    
    weak open var delegate: UserFindJobCategoryViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        view.bindToKeyboard()
        view.backgroundColor = .clear
        searchTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        fetchJobCategory()
    }
    
    public func fetchJobCategory() {
        let network = RestfulAPI<EMPTYMODEL,Generic<JobberCategoriesModel>>.init(path: "/user/categories")
            .with(auth: .user)
        handleRequestByUI(network) { [weak self] (response) in
            guard let self = self else { return }
            let items = response.data?.items ?? []
            let convertedItems = items.map { UserJobCategoryItem.category($0) }
            
            self.delegate?.handleFetchItems(results: convertedItems)
        }
    }
    
    @IBAction func backgroundViewGestureTapped(_ sender: Any) {
        performSegue(withIdentifier: unwindToUserFindJobViewController, sender: nil)
    }

    @IBAction func searchTextFieldEditingChanged(_ sender: UITextField) {
        delegate?.searchTextFieldEditingChanged(sender)
    }
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        delegate?.isExpanded = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == toUserJoberCategoryViewController else { return }
        let destinationNC = segue.destination as! UINavigationController
        let destinationVC = destinationNC.viewControllers.first as! UserJobCategoryViewController
        
        destinationVC.delegate = self
        delegate = destinationVC
    }
}

extension UserFindJobCategoryViewController: UserJobCategoryViewControllerDelegate {
    func tableViewExpandChanged(_ state: Bool, vc: UserJobCategoryViewController) {        
        if !state { view.endEditing(true) }
        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction]) {
            self.findJobViewbHeightConstraint.constant = state ? 644:160
            self.view.layoutIfNeeded()
        } completion: { (state) in
            if state { vc.reload() }
        }
    }
    
    func parentVC() -> UserFindJobCategoryViewController {
        self
    }
}

extension UserFindJobCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.isExpanded = true
    }
}
