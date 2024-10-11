//
//  UITableViewCell+Extension.swift
//  Tracker
//
//  Created by Pavel Bobkov on 25.09.2024.
//

import UIKit

extension UITableViewCell {
    
    func roundCorners(for indexPath: IndexPath, in tableView: UITableView, totalRows: Int, with radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        
        var corners: CACornerMask = []
        
        if indexPath.row == 0 {
            corners.insert([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        
        if indexPath.row == totalRows - 1 {
            corners.insert([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        self.layer.maskedCorners = corners
    }
}
