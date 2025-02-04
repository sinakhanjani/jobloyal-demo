//
//  ExpandableTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/18/1400 AP.
//

import UIKit

class ExpandableTableView: UITableView {
    override var contentSize:CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
