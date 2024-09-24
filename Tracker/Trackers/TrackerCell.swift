//
//  TrackerCell.swift
//  Tracker
//
//  Created by Pavel Bobkov on 24.09.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapButton(in cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: TrackerCellDelegate?
    
    static let identifier = "TrackerCell"
    
    static let cellHeight: CGFloat = 148
    static func getCellWidth(for collectionView: UICollectionView) -> CGFloat {
        (collectionView.bounds.width / 2) - 5
    }
    
    private let doneButtonSize: CGFloat = 34
    private let emojiBackgroundSize: CGFloat = 24
    
    // MARK: - View
    
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    private let daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = "0 дней"
        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        return view
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.clipsToBounds = true
        return button
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
    
    func configure(backgroundColor: UIColor, emoji: String, title: String) {
        backgroundCardView.backgroundColor = backgroundColor
        doneButton.backgroundColor = backgroundColor
        titleLabel.text = title
        emojiLabel.text = emoji
    }
    
    private func setup() {
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
        [backgroundCardView, titleLabel, daysCounterLabel, doneButton, emojiBackgroundView, emojiLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        doneButton.layer.cornerRadius = doneButtonSize / 2
        doneButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        emojiBackgroundView.layer.cornerRadius = emojiBackgroundSize / 2
        
        contentView.addSubview(backgroundCardView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(doneButton)
        contentView.addSubview(emojiBackgroundView)
        contentView.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundCardView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
        ])
        
        NSLayoutConstraint.activate([
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCounterLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: doneButtonSize),
            doneButton.widthAnchor.constraint(equalToConstant: doneButtonSize),
        ])
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: emojiBackgroundSize),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: emojiBackgroundSize),
        ])
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
        ])
    }
    
    @objc private func didTapButton() {
        delegate?.didTapButton(in: self)
    }
}
