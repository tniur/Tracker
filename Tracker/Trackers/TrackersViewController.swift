//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private var chosenFilter = Filters.getFromUserDefaults()
    
    private var currentDate: Date = Date()
    
    private let trackerManager = TrackerManager()
    
    private let trackerRecordStore = TrackerRecordStore()
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - View
    
    private let searchTextField = UISearchTextField()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private let placeholderView = PlaceholderView(frame: CGRect.zero, title: NSLocalizedString("whatGoingToTrack", comment: "Track goals"), image: UIImage(named: "empty_placeholder"))
    
    private let filterPlaceholderView = PlaceholderView(frame: CGRect.zero, title: NSLocalizedString("nothingFound", comment: "Nothing found"), image: UIImage(named: "nothing_found"))
    
    private let trackersCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        let collecion = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecion.backgroundColor = .ypBackground
        return collecion
    }()
    
    private let filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filters", comment: "Filters"), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlue
        return button
    }()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        navigationBarConfigure()
        setupSearchTextField()
        setupView()
        setupConstraints()
        setupCollection()
        setupTargets()
        
        trackerManager.delegate = self
        trackerManager.filterCategories()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBackground
        
        [searchTextField, placeholderView, filterPlaceholderView, trackersCollection, filtersButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            placeholderView.topAnchor.constraint(equalTo: trackersCollection.topAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: trackersCollection.bottomAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterPlaceholderView.topAnchor.constraint(equalTo: trackersCollection.topAnchor),
            filterPlaceholderView.bottomAnchor.constraint(equalTo: trackersCollection.bottomAnchor),
            filterPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            trackersCollection.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            trackersCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackersCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
        ])
    }
    
    private func setupSearchTextField() {
        searchTextField.placeholder = NSLocalizedString("search", comment: "Search")
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTargets() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        filtersButton.addTarget(self, action: #selector(filtersButtonAction), for: .touchUpInside)
    }
    
    private func setupCollection() {
        trackersCollection.delegate = self
        trackersCollection.dataSource = self
        trackersCollection.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        trackersCollection.register(TrackersCollectionSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersCollectionSupplementaryView.reuseId)
    }
    
    private func compareDates(firstDate: Date, secondDate: Date) -> ComparisonResult {
        let calendar = Calendar.current
        return calendar.compare(firstDate, to: secondDate, toGranularity: .day)
    }
    
    @objc private func filtersButtonAction() {
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        present(filtersViewController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackerManager.filterCategories()
    }
    
    @objc private func addButtonTapped() {
        let chooseTrackerTypeViewController = ChooseTrackerTypeViewController()
        present(chooseTrackerTypeViewController, animated: true)
    }
    
    @objc private func textFieldDidChange(_ searchField: UISearchTextField) {
        trackerManager.filterCategories()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func navigationBarConfigure() {
        navigationItem.title = NSLocalizedString("trackers", comment: "Trackers")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .ypText
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        definesPresentationContext = true
    }
    
    private func changeCollectionViewDisplay(isHidden: Bool) {
        filterPlaceholderView.isHidden = true
        placeholderView.isHidden = true
        filtersButton.isHidden = false
        
        trackersCollection.isHidden = isHidden
        
        if trackerManager.getAllTrackersCount() == 0 {
            placeholderView.isHidden = false
            filtersButton.isHidden = true
        } else {
            filterPlaceholderView.isHidden = false
        }
    }
    
    private func showDeleteConfirmationMenu(deleteActionHandler: @escaping () -> Void) {
        let actionSheet = UIAlertController(title: nil, message: NSLocalizedString("deleteConfirmation", comment: "Delete confirmation"), preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: .destructive) { _ in
            deleteActionHandler()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel, handler: nil)
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let number = trackerManager.getNumbersOfCategories()
        changeCollectionViewDisplay(isHidden: number == 0)
        
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = trackerManager.getNumbersOfTrackersInCategory(in: section)
        changeCollectionViewDisplay(isHidden: section == 0 && number == 0)
        
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.prepareForReuse()
        
        let tracker = trackerManager.getTracker(by: indexPath)
        let record = trackerRecordStore.countRecordsForTracker(byId: tracker.id)
        let isChecked = trackerRecordStore.isRecordExists(trackerId: tracker.id, date: currentDate)
        
        cell.configure(backgroundColor: tracker.color, emoji: tracker.emoji, title: tracker.name, record: record, isChecked: isChecked, isPinned: tracker.isPinned)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = TrackerCell.getCellWidth(for: collectionView)
        let height: CGFloat = TrackerCell.cellHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackersCollectionSupplementaryView.reuseId, for: indexPath) as? TrackersCollectionSupplementaryView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = trackerManager.getCategoryTitle(in: indexPath.section)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { _ in
            let tracker = self.trackerManager.getTracker(by: indexPath)
            let trackerCategories = self.trackerManager.getCategory(by: indexPath, for: tracker.isPinned)
            let record = self.trackerRecordStore.countRecordsForTracker(byId: tracker.id)
            
            let pinActionTitle = tracker.isPinned ? NSLocalizedString("unpin", comment: "Unpin action") : NSLocalizedString("pin", comment: "Pin action")
            
            let pinAction = UIAction(title: pinActionTitle, image: .none) { [weak self] _ in
                self?.trackerManager.changeTrackerPinState(for: tracker, isPinned: !tracker.isPinned)
            }
            
            let editAction = UIAction(title: NSLocalizedString("edit", comment: "Edit action"), image: .none) { [weak self] _ in
                let trackerType = tracker.timetable.isEmpty ? TrackerType.event : TrackerType.habbit
                let editTrackerViewController = EditTrackerViewController(trackerType: trackerType, tracker: tracker, category: trackerCategories, record: record)
                self?.present(editTrackerViewController, animated: true)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: "Delete action"), image: .none, attributes: .destructive) { [weak self] _ in
                self?.showDeleteConfirmationMenu { [weak self] in
                    self?.trackerManager.deleteTracker(tracker)
                }
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        })
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didTapButton(in cell: TrackerCell) {
        if compareDates(firstDate: currentDate, secondDate: Date()) == .orderedDescending { return }
        
        if let indexPath = trackersCollection.indexPath(for: cell) {
            let tracker = trackerManager.getTracker(by: indexPath)
            
            do {
                try trackerRecordStore.tryAddNewRecord(tracker.id, date: currentDate)
                trackersCollection.reloadItems(at: [indexPath])
            } catch {
                print("Error adding new record: \(error.localizedDescription)")
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if contentHeight != 0 && offsetY + scrollViewHeight >= contentHeight {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.filtersButton.alpha = 0
            }
        }
        
        if offsetY + scrollViewHeight < contentHeight {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.filtersButton.alpha = 1
            }
        }
    }
}

// MARK: - TrackerManagerDelegate

extension TrackersViewController: TrackerManagerDelegate {
    func getSearchedWord() -> String? {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            return searchText
        } else {
            return nil
        }
    }
    
    func didUpdate() {
        trackersCollection.reloadData()
    }
    
    func getCurrentWeekDay() -> WeekDay? {
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDateString = dateFormatter.string(from: currentDate)
        let currentWeekDay = WeekDay.getWeekDayFrom(dayName: currentDateString)
        return currentWeekDay
    }
    
    func getFilter() -> Filters {
        chosenFilter
    }
    
    func getCurrentDate() -> Date {
        currentDate
    }
}

// MARK: - FiltersViewControllerDelegate

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: Filters) {
        chosenFilter = filter
        
        if filter == .today {
            datePicker.setDate(Date(), animated: true)
            datePicker.sendActions(for: .valueChanged)
        } else {
            trackerManager.filterCategories()
        }
    }
}
