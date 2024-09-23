//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - View
    
    private let ErrorStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let ErrorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackers_error")
        return imageView
    }()
    
    private let ErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        navigationBarConfigure()
        
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        ErrorStack.addArrangedSubview(ErrorImageView)
        ErrorStack.addArrangedSubview(ErrorLabel)
        
        view.addSubview(ErrorStack)
    }
    
    private func setupConstraints() {
        ErrorStack.translatesAutoresizingMaskIntoConstraints = false
        ErrorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ErrorStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ErrorStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ErrorImageView.widthAnchor.constraint(equalToConstant: 80),
            ErrorImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func addButtonTapped() { }
    
    private func navigationBarConfigure() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
    }
}
