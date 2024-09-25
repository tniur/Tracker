//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 25.09.2024.
//

import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(_ tracker: Tracker, category: TrackerCategory)
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private var category: TrackerCategory? = TrackerCategory(title: "Работа", trackers: [])
    private var timetable = [WeekDay]()
    
    private let trackerType: TrackerType
    private let trackerSettingsCategory: [String]
    private let trackerSettingsTableViewCellHeight: CGFloat = 75
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        return label
    }()
    
    private let trackerTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = UIColor(named: "YP Black")
        textField.backgroundColor = UIColor(named: "YP BackgroundDay")
        textField.layer.cornerRadius = 16
        textField.leftIndent(size: 16)
        return textField
    }()
    
    private let trackerSettingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = UIColor(named: "YP Gray")
        return tableView
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cоздать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.backgroundColor = UIColor(named: "YP Gray")
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Life-Cycle
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        
        switch trackerType {
        case .habbit:
            titleLabel.text = "Новая привычка"
            trackerSettingsCategory = ["Категория", "Расписание"]
        case .event:
            titleLabel.text = "Новое нерегулярное событие"
            trackerSettingsCategory = ["Категория"]
        }
        
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
        setupView()
        setupConstraints()
        setupTableView()
        setupTargets()
        setupTextField()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [titleLabel, trackerTitleTextField, trackerSettingsTableView,
         buttonsStack, cancelButton, createButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, trackerTitleTextField, trackerSettingsTableView, buttonsStack].forEach { view.addSubview($0) }
        [cancelButton, createButton].forEach { buttonsStack.addArrangedSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            trackerTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerTitleTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            trackerSettingsTableView.topAnchor.constraint(equalTo: trackerTitleTextField.bottomAnchor, constant: 24),
            trackerSettingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerSettingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerSettingsTableView.heightAnchor.constraint(equalToConstant: trackerSettingsTableViewCellHeight*CGFloat(trackerSettingsCategory.count))
        ])
        
        NSLayoutConstraint.activate([
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTextField() {
        trackerTitleTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonAction), for: .touchUpInside)
        trackerTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupTableView() {
        trackerSettingsTableView.dataSource = self
        trackerSettingsTableView.delegate = self
        trackerSettingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func updateCreateButtonState() {
        switch trackerType {
        case .habbit:
            let isTextFieldFilled = !(trackerTitleTextField.text?.isEmpty ?? true)
            let isTimetableFilled = !timetable.isEmpty
            let isCategoryFilled = category != nil
            createButton.isEnabled = isTextFieldFilled && isTimetableFilled && isCategoryFilled
        case .event:
            let isTextFieldFilled = !(trackerTitleTextField.text?.isEmpty ?? true)
            let isCategoryFilled = category != nil
            createButton.isEnabled = isTextFieldFilled && isCategoryFilled
        }
        
        createButton.backgroundColor = createButton.isEnabled ? UIColor(named: "YP Black") : UIColor(named: "YP Gray")
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonAction() {
        guard let category = category,
              let trackerName = trackerTitleTextField.text else { return }
        let newTracker = Tracker(id: UUID(), name: trackerName, color: .red, emoji: "🏄‍♂️", timetable: timetable)
        
        delegate?.addNewTracker(newTracker, category: category)
        
        if let rootController = self.presentingViewController?.presentingViewController {
            rootController.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true)
        }
    }
}

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerSettingsCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "YP BackgroundDay")
        
        cell.textLabel?.text = trackerSettingsCategory[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        
        cell.detailTextLabel?.textColor = UIColor(named: "YP Gray")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        
        cell.roundCorners(for: indexPath, in: tableView, totalRows: trackerSettingsCategory.count, with: 16)
        
        switch indexPath.row {
        case 0:            
            guard let category else { return cell }
            cell.detailTextLabel?.text = category.title
        case 1:
            if !timetable.isEmpty {
                if timetable.count == 7 {
                    cell.detailTextLabel?.text = "Каждый день"
                } else {
                    let text = timetable.map { String($0.rawValue) }.joined(separator: ", ")
                    cell.detailTextLabel?.text = text
                }
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return trackerSettingsTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            let timetableViewController = TimetableViewController()
            timetableViewController.delegate = self
            present(timetableViewController, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreateTrackerViewController: TimetableViewControllerDelegate {
    func updateTimetable(with weekDays: [WeekDay]) {
        self.timetable = weekDays
        updateCreateButtonState()
        trackerSettingsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
    
    func getTimetable() -> [WeekDay] {
        timetable
    }
}

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
