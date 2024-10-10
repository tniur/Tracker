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
    
    private var сategories: [TrackerCategory] = []
    
    private let сategoryTableViewCellHeight: CGFloat = 75
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Категория"
        label.textColor = .ypBlack
        return label
    }()
    
    private let placeholderView = PlaceholderView(frame: CGRect.zero, title: "Привычки и события можно \nобъединить по смыслу", image: UIImage(named: "empty_placeholder"))
    
    private let сategoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YP Gray")
        return tableView
    }()
    
    private let createCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
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
    }
    
    private func setup() {
        viewModel?.fetchCategories()
        
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
        сategoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = UIColor(named: "YP BackgroundDay")
        cell.tintColor = UIColor(named: "YP Black")
        cell.textLabel?.text = сategories[indexPath.row].title
        cell.selectionStyle = .none
        
        cell.roundCorners(for: indexPath, in: tableView, totalRows: сategories.count, with: 16)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChooseCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return сategoryTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .ypBlue
        cell.accessoryView = checkmark
        
        viewModel?.chosenCategory(сategories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryView = .none
        viewModel?.chosenCategory(nil)
    }
}
