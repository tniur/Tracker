//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 09.10.2024.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let style: OnboardingPageStyle
    
    // MARK: - View
    
    private let onboardingBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let onboardingTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // MARK: - Life-sycle
    
    init(style: OnboardingPageStyle) {
        self.style = style
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        view.backgroundColor = .white
        
        [onboardingBackgroundImageView, onboardingTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        onboardingBackgroundImageView.image = style.image
        onboardingTitleLabel.text = style.title
        
        NSLayoutConstraint.activate([
            onboardingBackgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingBackgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboardingBackgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingBackgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            onboardingTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            onboardingTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
