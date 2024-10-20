//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentDate: Date = Date()
    
    private let trackerManager = TrackerManager()
    
    private let trackerRecordStore = TrackerRecordStore()
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - View
    
    private let searchBar = UISearchBar()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private let placeholderView = PlaceholderView(frame: CGRect.zero, title: "Что будем отслеживать?", image: UIImage(named: "empty_placeholder"))
    
    private let trackersCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        let collecion = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collecion
    }()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        navigationBarConfigure()
        setupSearchBar()
        setupView()
        setupConstraints()
        setupCollection()
        setupTargets()
        
        trackerManager.delegate = self
        trackerManager.filterCategories()
    }
    
    private func setupView() {
        [searchBar, placeholderView, trackersCollection].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        trackersCollection.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            placeholderView.topAnchor.constraint(equalTo: trackersCollection.topAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: trackersCollection.bottomAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            trackersCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            trackersCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackersCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTargets() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
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
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackerManager.filterCategories()
    }
    
    @objc private func addButtonTapped() {
        let chooseTrackerTypeViewController = ChooseTrackerTypeViewController()
        present(chooseTrackerTypeViewController, animated: true)
    }
    
    private func navigationBarConfigure() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        definesPresentationContext = true
    }
    
    private func changeCollectionViewDisplay(isHidden: Bool) {
        trackersCollection.isHidden = isHidden
        placeholderView.isHidden = !isHidden
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerManager.getNumbersOfCategories()
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
        
        cell.configure(backgroundColor: tracker.color, emoji: tracker.emoji, title: tracker.name, record: record, isChecked: isChecked)
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
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerManagerDelegate {
    func didUpdate() {
        trackersCollection.reloadData()
    }
    
    func getCurrentWeekDay() -> WeekDay? {
        dateFormatter.dateFormat = "EEEE"
        
        let currentDateString = dateFormatter.string(from: currentDate)
        let currentWeekDay = WeekDay.getWeekDayFrom(dayName: currentDateString)
        return currentWeekDay
    }
}
