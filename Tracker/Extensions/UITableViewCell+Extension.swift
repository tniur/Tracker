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
        self.layer.maskedCorners = []
        
        if indexPath.row == 0 {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == totalRows - 1 {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
}
