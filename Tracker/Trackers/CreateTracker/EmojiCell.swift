//
//  EmojiCell.swift
//  Tracker
//
//  Created by Pavel Bobkov on 27.09.2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseId = "EmojiCell"
    static let height: CGFloat = 52
    static let width: CGFloat = 52
    
    // MARK: - View
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
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
    
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func select() {
        contentView.backgroundColor = .ypLightGray
    }
    
    func deselect() {
        contentView.backgroundColor = .clear
    }
    
    private func setup() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
