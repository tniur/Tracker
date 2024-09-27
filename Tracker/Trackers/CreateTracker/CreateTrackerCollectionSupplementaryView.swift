//
//  CreateTrackerCollectionSupplementaryView.swift
//  Tracker
//
//  Created by Pavel Bobkov on 27.09.2024.
//

import UIKit

final class CreateTrackerCollectionSupplementaryView: UICollectionReusableView {
    static let reuseId = "CreateTrackerCollectionSupplementaryView"
    
    let titleLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(titleLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
            titleLabel.textColor = .ypBlack
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
