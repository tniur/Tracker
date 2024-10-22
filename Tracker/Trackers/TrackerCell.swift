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
    
    private let recordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypText
        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
        button.tintColor = .ypBackground
        button.clipsToBounds = true
        return button
    }()
    
    private let pinImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pin")
        return image
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
    
    func configure(backgroundColor: UIColor, emoji: String, title: String, record: Int, isChecked: Bool, isPinned: Bool) {
        backgroundCardView.backgroundColor = backgroundColor
        doneButton.backgroundColor = backgroundColor
        titleLabel.text = title
        emojiLabel.text = emoji
        
        let recordString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of record days"),
            record
        )
        recordLabel.text = recordString
        
        if isChecked {
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.alpha = 0.3
        } else {
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
            doneButton.alpha = 1
        }
        
        if isPinned {
            pinImage.isHidden = false
        } else {
            pinImage.isHidden = true
        }
    }
    
    private func setup() {
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        contentView.backgroundColor = .ypBackground
        
        doneButton.layer.cornerRadius = doneButtonSize / 2
        doneButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        emojiBackgroundView.layer.cornerRadius = emojiBackgroundSize / 2
        
        [backgroundCardView, titleLabel, recordLabel, doneButton, emojiBackgroundView, emojiLabel, pinImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
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
            recordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            recordLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
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
        
        NSLayoutConstraint.activate([
            pinImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            pinImage.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            pinImage.heightAnchor.constraint(equalToConstant: 24),
            pinImage.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    @objc private func didTapButton() {
        delegate?.didTapButton(in: self)
    }
}
