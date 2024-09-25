//
//  Untitled.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

extension UITextField {
    
    func leftIndent(size: CGFloat) {
        self.leftView = UIView(
            frame: .init(
                x: self.frame.minX,
                y: self.frame.minY,
                width: size,
                height: self.frame.height
            )
        )
        self.leftViewMode = .always
    }
}
