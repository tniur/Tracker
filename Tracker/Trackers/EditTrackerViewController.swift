//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 21.10.2024.
//

import UIKit

final class EditTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    private var category: TrackerCategory?
    private var timetable = [WeekDay]()
    private var selectedEmojiIndex: Int? = nil
    private var selectedColorIndex: Int? = nil
    
    private let trackerType: TrackerType
    private let tracker: Tracker
    private let trackerSettingsCategory: [String]
    private let trackerSettingsTableViewCellHeight: CGFloat = 75
    
    private let trackerStore = TrackerStore()
    
    private let collectionViewSections: [CollectionSection] = [
        CollectionSection(title: NSLocalizedString("emoji", comment: "emoji"), items: Constants.trackerEmoji),
        CollectionSection(title: NSLocalizedString("color", comment: "color"), items: Constants.trackerColours)
    ]
    
    // MARK: - View
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentContainerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private let trakerRecordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private let trackerTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("enterTrackerName", comment: "color")
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlack
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
        tableView.separatorColor = .ypGray
        return tableView
    }()
    
    private let trackerStyleConfigureCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        let collecion = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collecion
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
        button.setTitle(NSLocalizedString("cancel", comment: "cancel button"), for: .normal)
        button.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("save", comment: "save button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Life-Cycle
    
    init(trackerType: TrackerType, tracker: Tracker, category: TrackerCategory, record: Int) {
        self.trackerType = trackerType
        self.tracker = tracker
        
        switch trackerType {
        case .habbit:
            titleLabel.text = NSLocalizedString("editHabbit", comment: "Edit habbit")
            trackerSettingsCategory = [NSLocalizedString("category", comment: "Сategory"), NSLocalizedString("schedule", comment: "Сategory")]
        case .event:
            titleLabel.text = NSLocalizedString("editEvent", comment: "Edit event")
            trackerSettingsCategory = [NSLocalizedString("category", comment: "Сategory")]
        }
        
        super.init(nibName: nil, bundle: nil)
        
        trackerTitleTextField.text = tracker.name
        let recordString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of record days"),
            record
        )
        trakerRecordLabel.text = recordString
        self.updateTimetable(with: tracker.timetable)
        self.updateCategory(category)
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
        setupCollectionView()
        setupTargets()
        setupTextField()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [scrollView, contentContainerView, titleLabel, trakerRecordLabel, trackerTitleTextField,
         trackerSettingsTableView, trackerStyleConfigureCollectionView,
         buttonsStack, cancelButton, saveButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, scrollView, buttonsStack].forEach { view.addSubview($0) }
        [trakerRecordLabel, trackerTitleTextField, trackerSettingsTableView, trackerStyleConfigureCollectionView].forEach { contentContainerView.addSubview($0) }
        [cancelButton, saveButton].forEach { buttonsStack.addArrangedSubview($0) }
        
        scrollView.addSubview(contentContainerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentContainerView.heightAnchor.constraint(equalToConstant: 900),
        ])
        
        NSLayoutConstraint.activate([
            trakerRecordLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 22),
            trakerRecordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerTitleTextField.topAnchor.constraint(equalTo: trakerRecordLabel.bottomAnchor, constant: 40),
            trackerTitleTextField.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16),
            trackerTitleTextField.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            trackerTitleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            trackerSettingsTableView.topAnchor.constraint(equalTo: trackerTitleTextField.bottomAnchor, constant: 24),
            trackerSettingsTableView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16),
            trackerSettingsTableView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            trackerSettingsTableView.heightAnchor.constraint(equalToConstant: trackerSettingsTableViewCellHeight*CGFloat(trackerSettingsCategory.count)),
            
            trackerStyleConfigureCollectionView.topAnchor.constraint(equalTo: trackerSettingsTableView.bottomAnchor, constant: 14),
            trackerStyleConfigureCollectionView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16),
            trackerStyleConfigureCollectionView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            trackerStyleConfigureCollectionView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
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
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        trackerTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupTableView() {
        trackerSettingsTableView.dataSource = self
        trackerSettingsTableView.delegate = self
        trackerSettingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupCollectionView() {
        trackerStyleConfigureCollectionView.dataSource = self
        trackerStyleConfigureCollectionView.delegate = self
        trackerStyleConfigureCollectionView.allowsMultipleSelection = true
        trackerStyleConfigureCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
        trackerStyleConfigureCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        trackerStyleConfigureCollectionView.register(CreateTrackerCollectionSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CreateTrackerCollectionSupplementaryView.reuseId)
    }
    
    private func updateSaveButtonState() {
        switch trackerType {
        case .habbit:
            let isTextFieldFilled = !(trackerTitleTextField.text?.isEmpty ?? true)
            let isTimetableFilled = !timetable.isEmpty
            let isCategoryFilled = category != nil
            let isEmojiSelected = selectedEmojiIndex != nil
            let isColorSelected = selectedColorIndex != nil
            saveButton.isEnabled = isTextFieldFilled && isTimetableFilled && isCategoryFilled && isEmojiSelected && isColorSelected
        case .event:
            let isTextFieldFilled = !(trackerTitleTextField.text?.isEmpty ?? true)
            let isCategoryFilled = category != nil
            let isEmojiSelected = selectedEmojiIndex != nil
            let isColorSelected = selectedColorIndex != nil
            saveButton.isEnabled = isTextFieldFilled && isCategoryFilled && isEmojiSelected && isColorSelected
        }
        
        saveButton.backgroundColor = saveButton.isEnabled ? UIColor(named: "YP Black") : UIColor(named: "YP Gray")
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonAction() {
        guard let category = category,
              let trackerName = trackerTitleTextField.text,
              let selectedEmojiIndex = selectedEmojiIndex,
              let selectedColorIndex = selectedColorIndex,
              let emoji = collectionViewSections[0].items[selectedEmojiIndex] as? String,
              let color = collectionViewSections[1].items[selectedColorIndex] as? UIColor else { return }
        
        let newTracker = Tracker(id: tracker.id, name: trackerName, color: color, emoji: emoji, timetable: timetable, isPinned: tracker.isPinned)
        
        do {
            try trackerStore.updateTracker(newTracker, category)
        } catch {
            print("Error update new tracker: \(error.localizedDescription)")
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension EditTrackerViewController: UITableViewDataSource, UITableViewDelegate {
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
                    cell.detailTextLabel?.text = NSLocalizedString("daily", comment: "Daily")
                } else {
                    let text = timetable.map { String($0.localized) }.joined(separator: ", ")
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
            let chooseCategoryViewModel = ChooseCategoryViewModel()
            chooseCategoryViewModel.delegate = self
            chooseCategoryViewModel.previousChosenCategory = category
            let createCategoryViewController = ChooseCategoryViewController(viewModel: chooseCategoryViewModel)
            present(createCategoryViewController, animated: true)
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

// MARK: - TimetableViewControllerDelegate

extension EditTrackerViewController: TimetableViewControllerDelegate {
    func updateTimetable(with weekDays: [WeekDay]) {
        self.timetable = weekDays
        updateSaveButtonState()
        trackerSettingsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
    
    func getTimetable() -> [WeekDay] {
        timetable
    }
}

// MARK: - UITextFieldDelegate

extension EditTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UICollectionViewDataSource

extension EditTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionViewSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewSections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        
        let items = collectionViewSections[indexPath.section].items
        if let emoji = items[indexPath.row] as? String {
            guard let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            emojiCell.configure(emoji: emoji)
            if emoji == tracker.emoji {
                emojiCell.select()
                selectedEmojiIndex = indexPath.row
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
            cell = emojiCell
        } else if let color = items[indexPath.row] as? UIColor {
            guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            colorCell.configure(color: color)
            if color.cgColor.components == tracker.color.cgColor.components {
                colorCell.select()
                selectedColorIndex = indexPath.row
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
            cell = colorCell
        }
        
        updateSaveButtonState()
        
        cell?.prepareForReuse()
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: EmojiCell.width, height: EmojiCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CreateTrackerCollectionSupplementaryView.reuseId, for: indexPath) as? CreateTrackerCollectionSupplementaryView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = collectionViewSections[indexPath.section].title
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension EditTrackerViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
            if selectedEmojiIndex == nil {
                selectedEmojiIndex = indexPath.row
                cell.select()
            } else {
                guard let previousSelectedEmojiIndex = selectedEmojiIndex else { return }
                let previousIndexPath = IndexPath(row: previousSelectedEmojiIndex, section: indexPath.section)
                guard let prevCell = collectionView.cellForItem(at: previousIndexPath) as? EmojiCell else { return }
                collectionView.deselectItem(at: previousIndexPath, animated: false)
                
                selectedEmojiIndex = indexPath.row
                cell.select()
                prevCell.deselect()
            }
        } else if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
            if selectedColorIndex == nil {
                selectedColorIndex = indexPath.row
                cell.select()
            } else {
                guard let previousIndex = selectedColorIndex else { return }
                let previousIndexPath = IndexPath(row: previousIndex, section: indexPath.section)
                guard let prevCell = collectionView.cellForItem(at: previousIndexPath) as? ColorCell else { return }
                collectionView.deselectItem(at: previousIndexPath, animated: false)
                
                selectedColorIndex = indexPath.row
                cell.select()
                prevCell.deselect()
            }
        }
        updateSaveButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
            cell.deselect()
            selectedEmojiIndex = nil
        } else if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
            cell.deselect()
            selectedColorIndex = nil
        }
        updateSaveButtonState()
    }
}

// MARK: - ChooseCategoryViewModelProtocol
extension EditTrackerViewController: ChooseCategoryViewModelProtocol {
    func updateCategory(_ category: TrackerCategory?) {
        self.category = category
        trackerSettingsTableView.reloadData()
        updateSaveButtonState()
    }
}
