//
//  ChooseCategoryCell.swift
//  Tracker
//
//  Created by Pavel Bobkov on 11.10.2024.
//

import UIKit

final class ChooseCategoryCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseId = "ChooseCategoryCell"
    static let height: CGFloat = 75
    
    private var maskedCorners: CACornerMask = []
    
    // MARK: - View
    
    private let titleView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "YP Black")
        label.textColor = .label
        return label
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        return view
    }()
    
    // MARK: - Life-Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        maskedCorners = []
        contentView.layer.maskedCorners = maskedCorners
        separatorView.isHidden = false
    }
    
    // MARK: - Methods
    
    func configure(title:  String) {
        titleView.text = title
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        checkmarkImage.isHidden = !selected
    }
    
    func isFirst() {
        contentView.layer.cornerRadius = 16
        maskedCorners.insert([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        contentView.layer.maskedCorners = maskedCorners
    }
    
    func isLast() {
        contentView.layer.cornerRadius = 16
        maskedCorners.insert([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        contentView.layer.maskedCorners = maskedCorners
        separatorView.isHidden = true
    }
    
    private func setupView() {
        contentView.backgroundColor = UIColor(named: "YP BackgroundDay")
        contentView.layer.masksToBounds = true
        
        [titleView, checkmarkImage, separatorView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        checkmarkImage.isHidden = true
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            checkmarkImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 20),
            checkmarkImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
