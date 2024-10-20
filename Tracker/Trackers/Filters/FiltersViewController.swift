//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 20.10.2024.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: Filters)
}

final class FiltersViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: FiltersViewControllerDelegate?
    
    private var selectedFilter: Filters?
    
    private let filters: [Filters] = [.all, .today, .completed, .notCompleted]
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("filters", comment: "Filters")
        label.textColor = .ypBlack
        return label
    }()
    
    private let filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        setupView()
        setupTableView()
        setupConstraints()
        getSelectedFilter()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [titleLabel, filtersTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupTableView() {
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.isMultipleTouchEnabled = false
        filtersTableView.register(ChooseItemCell.self, forCellReuseIdentifier: ChooseItemCell.reuseId)
    }
    
    private func getSelectedFilter() {
        if let savedFilter = UserDefaults.standard.data(forKey: "trackersFilter") {
            do {
                selectedFilter = try JSONDecoder().decode(Filters.self, from: savedFilter)
            } catch {
                selectedFilter = .all
            }
        } else {
            selectedFilter = .all
        }
    }
    
    private func saveSelectedFilter(by index: Int) {
        if let encoded = try? JSONEncoder().encode(filters[index]) {
            UserDefaults.standard.set(encoded, forKey: "trackersFilter")
        }
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChooseItemCell.reuseId, for: indexPath) as? ChooseItemCell else {
            return UITableViewCell()
        }
        
        cell.prepareForReuse()
        cell.selectionStyle = .none
        cell.configure(title: filters[indexPath.row].localised())
        
        if indexPath.row == 0 {
            cell.isFirst()
        }
        if indexPath.row == filters.count - 1 {
            cell.isLast()
        }
        
        if selectedFilter == filters[indexPath.row] {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ChooseItemCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveSelectedFilter(by: indexPath.row)
        dismiss(animated: true)
    }
}
