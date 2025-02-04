//
//  AutoDimensionTableView.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/26/1400 AP.
//

import UIKit


class AutoDimenstionTableView: UITableView {
    override var contentSize:CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
