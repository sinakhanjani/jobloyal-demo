//
//  JobberRequestCollectionViewCell.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/5/1400 AP.
//

import UIKit

protocol JobberRequestCollectionViewCellButtonDelegate: AnyObject {
    func rejectButtonTapped(cell: UICollectionViewCell)
    func nextButtonTapped(cell: UICollectionViewCell)
}

protocol JobberNumericRequestCollectionViewCellDelegate: AnyObject {
    func requestServiceDidSelected(cell: JobberNumericRequestCollectionViewCell, selectedServiceIndexPath: IndexPath)
}

class JobberNumericRequestCollectionViewCell: UICollectionViewCell {    

    enum Section {
        case main
    }

    private var tableViewViewDataSource: UITableViewDiffableDataSource<Section, JobberRequestServiceModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, JobberRequestServiceModel>()
    
    public var items: [JobberRequestServiceModel] = []
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    weak open var delegate: JobberNumericRequestCollectionViewCellDelegate?
    var buttonDelegate: JobberRequestCollectionViewCellButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    func updateUI(remainingTime: Int, items: [JobberRequestServiceModel]?, jobName: String, distance: Double, totalPrice: Double, address: String) {
        let elapsedTimeInSecond = remainingTime
        let seconds = elapsedTimeInSecond % 60
        let minutes = (elapsedTimeInSecond / 60) % 60
        let secendText = String(format: "%02d", seconds)
        let minuteText = String(format: "%02d", minutes)
        
        rejectButton.setTitle("Reject".localized() + " \(minuteText):\(secendText)", for: .normal)
        
        addressLabel.text = address
        jobNameLabel.text = jobName
        priceLabel.text = "\(totalPrice.toPriceFormatter)"
        distanceLabel.text = "\(Double(distance/1000).rounded(toPlaces: 2)) KM"
        
        // Next total price:
        if let items = items {
            let nextTotalPrice = items.reduce(0) { (oldPrice, item) -> Double in
                return item.isSelected! ? (oldPrice + item.price): oldPrice
            }
            
            nextButton.setTitle("Next".localized() + " \(nextTotalPrice.toPriceFormatter) CHF", for: .normal)
        }
        
        // reload snapshot tableView
        self.items = items ?? []
        snapshot = createSnapshot()
        tableViewViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configUI() {
        perform()
    }
    
    private func createSnapshot() -> NSDiffableDataSourceSnapshot<Section, JobberRequestServiceModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,JobberRequestServiceModel>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: Section.main)

        return snapshot
    }
    
    private func perform() {
        tableView.delegate = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 80
        
        snapshot = createSnapshot()
        
        let nib = UINib(nibName: NumericRequestTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NumericRequestTableViewCell.identifier)

        dataSource()
        
        tableViewViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func dataSource() {
        tableViewViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: NumericRequestTableViewCell.identifier, for: indexPath) as! NumericRequestTableViewCell
            cell.accessoryType = item.isSelected! ? .checkmark:.none
            cell.updateUI(servicePrice: item.price, serviceName: item.title ?? "-", unitName: item.unit ?? "-")
            
            return cell
        })
    }
    
    // MARK: IBACTION
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        buttonDelegate?.nextButtonTapped(cell: self)
    }
    
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        buttonDelegate?.rejectButtonTapped(cell: self)
    }
}

extension JobberNumericRequestCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.requestServiceDidSelected(cell: self, selectedServiceIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
