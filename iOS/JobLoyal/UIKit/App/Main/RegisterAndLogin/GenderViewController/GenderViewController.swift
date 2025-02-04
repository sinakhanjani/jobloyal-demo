//
//  JenderViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

protocol GenderViewControllerDelegate: AnyObject {
    func selected(gender: Gender)
}

class GenderViewController: InterfaceViewController {
    
    enum Section {
        case main
    }

    @IBOutlet weak var tableView: UITableView!
    
    private var tableViewViewDataSource: UITableViewDiffableDataSource<Section, Gender>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Gender>()
    private let gender: [Gender] = [.men, .women]
    
    weak open var delegate: GenderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, Gender> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Gender>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(gender, toSection: Section.main)

        return snapshot
    }
    
    private func perform() {
        snapshot = createSnapshot()

        dataSource()
        
        tableViewViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func dataSource() {
        tableViewViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
            
            cell.imageView?.image = item.image
            cell.textLabel?.text = item.value
            
            return cell
        })
    }
}

extension GenderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PASSING DATA
        let item = gender[indexPath.item]
        
        delegate?.selected(gender: item)
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
