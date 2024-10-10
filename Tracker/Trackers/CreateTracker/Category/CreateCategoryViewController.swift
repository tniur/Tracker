//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 10.10.2024.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    private let trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Новая категория"
        label.textColor = .ypBlack
        return label
    }()
    
    private let categoryTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlack
        textField.backgroundColor = UIColor(named: "YP BackgroundDay")
        textField.layer.cornerRadius = 16
        textField.leftIndent(size: 16)
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.backgroundColor = .ypGray
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
        setupTextField()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [titleLabel, categoryTitleTextField, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTitleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTextField() {
        categoryTitleTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateButtonState() {
        guard let text = categoryTitleTextField.text else { return }
        
        let isEnable = !text.isEmpty && !text.trimmingCharacters(in: .whitespaces).isEmpty
        
        doneButton.isEnabled = isEnable
        doneButton.backgroundColor = isEnable ? .ypBlack : .ypGray
    }
    
    @objc private func doneButtonTapped() {
        guard let title = categoryTitleTextField.text else { return }
        
        do {
            try trackerCategoryStore.tryAddNewCategory(with: title)
        } catch {
            print("Error adding new category: \(error.localizedDescription)")
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButtonState()
    }
}
