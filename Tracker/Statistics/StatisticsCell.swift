//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Pavel Bobkov on 18.10.2024.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier: String = "StatisticsCell"
    
    static let cellHeight: CGFloat = 102
    
    // MARK: - View
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let recordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life-Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientBorder()
    }
    
    // MARK: - Methods
    
    func configure(record: String, subtitle: String) {
        recordLabel.text = record
        subtitleLabel.text = subtitle
    }
    
    private func setup() {
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .ypBackground

        contentView.addSubview(containerView)
        [recordLabel, subtitleLabel].forEach { containerView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            recordLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            recordLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupGradientBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.bounds
        gradientLayer.colors = [
            UIColor.ypRed.cgColor,
            UIColor.ypGreen.cgColor,
            UIColor.ypBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        containerView.layer.addSublayer(gradientLayer)
    }
}
