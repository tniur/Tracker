//
//  ColorCell.swift
//  Tracker
//
//  Created by Pavel Bobkov on 27.09.2024.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseId = "ColorCell"
    static let height: CGFloat = 52
    static let width: CGFloat = 52
    
    // MARK: - View
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: - Life-Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Methods
    
    func configure(color: UIColor) {
        colorView.backgroundColor = color
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func select() {
        contentView.layer.borderWidth = 3
    }
    
    func deselect() {
        contentView.layer.borderWidth = 0
    }
    
    private func setup() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
