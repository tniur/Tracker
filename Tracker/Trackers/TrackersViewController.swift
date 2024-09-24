//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(_ tracker: Tracker, category: TrackerCategory)
}

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentDate: Date = Date()
    private var categories: [TrackerCategory] = [TrackerCategory(title: "Работа", trackers: []), TrackerCategory(title: "Учеба", trackers: [])]
    private var filteredByDateCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackersRecords = [String: Int]()
    private let dateFormatter = DateFormatter()
    
    // MARK: - View
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private let errorStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackers_error")
        return imageView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
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
        setupView()
        setupConstraints()
        setupCollection()
        setupTargets()
        
        updateTrackersCollection()
    }
    
    private func setupView() {
        [errorStack, errorImageView, trackersCollection].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        errorStack.addArrangedSubview(errorImageView)
        errorStack.addArrangedSubview(errorLabel)
        
        view.addSubview(errorStack)
        view.addSubview(trackersCollection)
        
        errorStack.isHidden = true
        trackersCollection.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            errorStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            trackersCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackersCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
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
    
    private func filterCategoriesByDate() {
        dateFormatter.dateFormat = "EEEE"
        filteredByDateCategories.removeAll()
        
        guard let weekDay = WeekDay.getWeekDayFrom(dayName: dateFormatter.string(from: currentDate)) else {
            return
        }
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.timetable.contains(weekDay) || tracker.timetable.isEmpty
            }
            
            if !filteredTrackers.isEmpty {
                filteredByDateCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        
        if filteredByDateCategories.isEmpty {
            errorStack.isHidden = false
            trackersCollection.isHidden = true
        } else {
            errorStack.isHidden = true
            trackersCollection.isHidden = false
        }
    }
    
    private func updateTrackersCollection() {
        filterCategoriesByDate()
        trackersCollection.reloadData()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateTrackersCollection()
    }
    
    @objc private func addButtonTapped() {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        present(createTrackerViewController, animated: true)
    }
    
    private func navigationBarConfigure() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func addNewTracker(_ tracker: Tracker, category: TrackerCategory) {
        var newCategories: [TrackerCategory] = []
        
        categories.forEach {
            if $0.title != category.title {
                newCategories.append($0)
            } else {
                let title = $0.title
                let trackers = $0.trackers + [tracker]
                let newCategory = TrackerCategory(title: title, trackers: trackers)
                newCategories.append(newCategory)
            }
        }
        
        trackersRecords[tracker.id.uuidString] = 0
        categories = newCategories
        updateTrackersCollection()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredByDateCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredByDateCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.prepareForReuse()
        
        let tracker = filteredByDateCategories[indexPath.section].trackers[indexPath.row]
        
        var isChecked = false
        
        completedTrackers.forEach {
            if $0.trackerId == tracker.id && $0.date == currentDate {
                isChecked = true
            }
        }
        
        cell.configure(backgroundColor: tracker.color, emoji: tracker.emoji, title: tracker.name, record: trackersRecords[tracker.id.uuidString] ?? 0, isChecked: isChecked)
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
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackersCollectionSupplementaryView.reuseId, for: indexPath) as! TrackersCollectionSupplementaryView
        
        header.titleLabel.text = filteredByDateCategories[indexPath.section].title
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didTapButton(in cell: TrackerCell) {
        if let indexPath = trackersCollection.indexPath(for: cell) {
            if currentDate > Date() { return }
            
            let tracker = filteredByDateCategories[indexPath.section].trackers[indexPath.row]
            
            let isChecked = cell.getChecked()
            
            if isChecked {
                for i in 0 ..< completedTrackers.count {
                    if completedTrackers[i].trackerId == tracker.id && completedTrackers[i].date == currentDate {
                        completedTrackers.remove(at: i)
                        if let currentCount = trackersRecords[tracker.id.uuidString] {
                            trackersRecords[tracker.id.uuidString] = currentCount - 1
                        }
                        break
                    }
                }
            } else {
                completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: currentDate))
                if let currentCount = trackersRecords[tracker.id.uuidString] {
                    trackersRecords[tracker.id.uuidString] = currentCount + 1
                }
            } 
            cell.updateButton()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let _ = searchController.searchBar.text ?? ""
    }
}
