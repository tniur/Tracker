//
//  ChooseTrackerTypeViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

final class ChooseTrackerTypeViewController: UIViewController {
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("creatingTracker", comment: "Creating tracker")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        return label
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("habbit", comment: "Habbit"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let irregularEventsButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("irregularEvent", comment: "An irregular event"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        setupView()
        setupButtonsAction()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let views = [titleLabel, buttonsStack, habitButton, irregularEventsButton]
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        [titleLabel, buttonsStack].forEach { view.addSubview($0) }
        [habitButton, irregularEventsButton].forEach { buttonsStack.addArrangedSubview($0) }
    }
    
    private func setupButtonsAction() {
        habitButton.addTarget(self, action: #selector(habbitButtonAction), for: .touchUpInside)
        irregularEventsButton.addTarget(self, action: #selector(irregularEventsButtonAction), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habbitButtonAction() {
        let createTrackerViewController = CreateTrackerViewController(trackerType: .habbit)
        createTrackerViewController.modalTransitionStyle = .coverVertical
        present(createTrackerViewController, animated: true)
    }
    
    @objc private func irregularEventsButtonAction() {
        let createTrackerViewController = CreateTrackerViewController(trackerType: .event)
        createTrackerViewController.modalTransitionStyle = .coverVertical
        present(createTrackerViewController, animated: true)
    }
}
