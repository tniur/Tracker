//
//  ChooseCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 10.10.2024.
//

import UIKit

final class ChooseCategoryViewController: UIViewController {
    
    // MARK: - Preperties
    
    private var viewModel: ChooseCategoryViewModel?
    
    private var previousChosenCategory: TrackerCategory?
    
    private var сategories: [TrackerCategory] = []
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("category", comment: "Category")
        label.textColor = .ypBlack
        return label
    }()
    
    private let placeholderView = PlaceholderView(frame: CGRect.zero, title: NSLocalizedString("habitsAndEventsCombinedInfo", comment: "Habits and events combined info"), image: UIImage(named: "empty_placeholder"))
    
    private let сategoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("addCategory", comment: "Add category"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Life-Cycle
    
    
    init(viewModel: ChooseCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Methods
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onCategoriesListStateChange = { [weak self] сategories in
            self?.сategories = сategories
            self?.сategoryTableView.reloadData()
        }
        
        viewModel.onPreviousChosenCategoryStateChange = { [weak self] previousChosenCategory in
            self?.previousChosenCategory = previousChosenCategory
        }
    }
    
    private func setup() {
        viewModel?.fetchCategories()
        viewModel?.setupPreviousChosenCategory()
        
        setupView()
        setupTableView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [titleLabel, placeholderView, сategoryTableView, createCategoryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        createCategoryButton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        сategoryTableView.isHidden = true
    }
    
    private func setupTableView() {
        сategoryTableView.dataSource = self
        сategoryTableView.delegate = self
        сategoryTableView.isMultipleTouchEnabled = false
        сategoryTableView.register(ChooseCategoryCell.self, forCellReuseIdentifier: ChooseCategoryCell.reuseId)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            сategoryTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            сategoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            сategoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            сategoryTableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -10),
            
            placeholderView.topAnchor.constraint(equalTo: сategoryTableView.topAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: сategoryTableView.bottomAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func changeTableViewDisplay(isHidden: Bool) {
        сategoryTableView.isHidden = isHidden
        placeholderView.isHidden = !isHidden
    }
    
    @objc private func createCategoryButtonTapped() {
        let createCategoryViewController = CreateCategoryViewController()
        present(createCategoryViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChooseCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        changeTableViewDisplay(isHidden: сategories.isEmpty)
        
        return сategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChooseCategoryCell.reuseId, for: indexPath) as? ChooseCategoryCell else {
            return UITableViewCell()
        }
        
        cell.prepareForReuse()
        cell.selectionStyle = .none
        cell.configure(title: сategories[indexPath.row].title)
        
        if indexPath.row == 0 {
            cell.isFirst()
        }
        if indexPath.row == сategories.count - 1 {
            cell.isLast()
        }
        
        if previousChosenCategory?.title == сategories[indexPath.row].title {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChooseCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChooseCategoryCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.chosenCategory(сategories[indexPath.row])
        dismiss(animated: true)
    }
}
