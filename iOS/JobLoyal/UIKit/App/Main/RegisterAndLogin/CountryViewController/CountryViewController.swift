//
//  CountryViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/1/1400 AP.
//

import UIKit

protocol CountryViewControllerDelegate: AnyObject {
    func selected(country: Country)
}

class CountryViewController: InterfaceViewController {
    
    enum Section {
        case main
    }

    @IBOutlet weak var tableView: UITableView!
    
    private var tableViewViewDataSource: UITableViewDiffableDataSource<Section, Country>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Country>()
    private let countries: [Country] = Country.countries
    
    weak var delegate: CountryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, Country> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Country>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(countries, toSection: Section.main)

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
            cell.textLabel?.text = item.name
            
            return cell
        })
    }
}

extension CountryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PASSING DATA
        let country = countries[indexPath.item]
        
        delegate?.selected(country: country)
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
