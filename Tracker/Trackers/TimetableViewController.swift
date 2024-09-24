//
//  TimetableViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

protocol TimetableViewControllerDelegate: AnyObject {
    func getTimetable() -> [WeekDay]
    func updateTimetable(with weekDays: [WeekDay])
}

final class TimetableViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: TimetableViewControllerDelegate?
    
    private var selectedWeekDays = [(WeekDay.monday, false), (WeekDay.tuesday, false), (WeekDay.wednesday, false), (WeekDay.thursday, false), (WeekDay.friday, false), (WeekDay.saturday, false), (WeekDay.sunday, false)]
    private let timetableTableViewCategory = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private let timetableTableViewCellHeight: CGFloat = 75
    
    // MARK: - View
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        return label
    }()
    
    private let timetableTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = UIColor(named: "YP Gray")
        return tableView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP Black")
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
        setupConstraints()
        setupSelectedWeekDays()
        setupTableView()
        setupButtonsAction()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let views = [titleLabel, timetableTableView, doneButton]
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        view.addSubview(titleLabel)
        view.addSubview(timetableTableView)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            timetableTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            timetableTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timetableTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timetableTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButtonsAction() {
        doneButton.addTarget(self, action: #selector(doneButtonButtonAction), for: .touchUpInside)
    }
    
    private func setupSelectedWeekDays() {
        let previousWeekDays = delegate?.getTimetable() ?? []
        
        for i in 0..<selectedWeekDays.count {
            if previousWeekDays.contains(selectedWeekDays[i].0) {
                selectedWeekDays[i].1 = true
            }
        }
    }
    
    private func setupTableView() {
        timetableTableView.dataSource = self
        timetableTableView.delegate = self
        timetableTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func doneButtonButtonAction() {
        var timetable = [WeekDay]()
        
        selectedWeekDays.forEach {
            if $0.1 {
                timetable.append($0.0)
            }
        }
        
        delegate?.updateTimetable(with: timetable)
        dismiss(animated: true)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            selectedWeekDays[sender.tag].1 = true
        } else {
            selectedWeekDays[sender.tag].1 = false
        }
    }
}

extension TimetableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timetableTableViewCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = UIColor(named: "YP BackgroundDay")
        cell.tintColor = UIColor(named: "YP Black")
        cell.textLabel?.text = timetableTableViewCategory[indexPath.row]
        cell.isSelected = false
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        if selectedWeekDays[indexPath.row].1 {
            switchView.setOn(true, animated: true)
        }
        switchView.onTintColor = UIColor(named: "YP Blue")
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        switch indexPath.row {
        case 0:
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case timetableTableViewCategory.count-1:
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return timetableTableViewCellHeight
    }
}
