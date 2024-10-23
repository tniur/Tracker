//
//  PlaceholderView.swift
//  Tracker
//
//  Created by Pavel Bobkov on 10.10.2024.
//

import UIKit

final class PlaceholderView: UIView {
    
    // MARK: - View
    
    private let placeholderStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let placeholderImageView: UIImageView = UIImageView()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypText
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life-Cycle
    
    init(frame: CGRect, title: String, image: UIImage?) {
        super.init(frame: frame)
        
        placeholderLabel.text = title
        placeholderImageView.image = image
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(placeholderStack)
        
        [placeholderStack, placeholderImageView, placeholderLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [placeholderImageView, placeholderLabel].forEach { placeholderStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            placeholderStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
}
