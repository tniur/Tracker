//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var trackersCompleted: Int? = nil
    
    private let statisticsCategories: [StatisticsCategory] = [.bestPeriod, .perfectDays, .trackersCompleted, .averageValue]
    
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - View
    
    private let placeholderView = PlaceholderView(frame: CGRect.zero, title: NSLocalizedString("nothingToAnalyze", comment: "Nothing to analyze"), image: UIImage(named: "statistic_error_placeholder"))
    
    private let statisticsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .ypBackground
        return tableView
    }()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatisticsData()
    }
    
    // MARK: - Methods
    
    private func setup() {
        navigationBarConfigure()
        setupView()
        setupTableView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBackground
        
        [placeholderView, statisticsTableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupTableView() {
        statisticsTableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
        statisticsTableView.dataSource = self
        statisticsTableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            statisticsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            statisticsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func navigationBarConfigure() {
        navigationItem.title = NSLocalizedString("statistics", comment: "Statistics")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func updateStatisticsData() {
        do {
            let trackersCompletedCount = try trackerRecordStore.getRecordsCount()
            trackersCompleted = trackersCompletedCount
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
        }
        
        if let count = trackersCompleted {
            statisticsTableView.isHidden = count > 0 ? false : true
            placeholderView.isHidden = count > 0 ? true : false
        }
        statisticsTableView.reloadData()
    }
}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        statisticsCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier, for: indexPath) as? StatisticsCell else {
            return UITableViewCell()
        }
    
        var record = 0
        let subtitle = statisticsCategories[indexPath.row].localized
        
        if statisticsCategories[indexPath.row] == .trackersCompleted,
        let trackersCompleted = trackersCompleted {
            record = trackersCompleted
        }
        
        cell.configure(record: String(record), subtitle: subtitle)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        StatisticsCell.cellHeight
    }
}
