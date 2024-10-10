//
//  ChooseCategoryViewModel.swift
//  Tracker
//
//  Created by Pavel Bobkov on 10.10.2024.
//

protocol ChooseCategoryViewModelProtocol: AnyObject {
    func updateCategory(_ category: TrackerCategory?)
}

typealias Binding<T> = (T) -> Void

final class ChooseCategoryViewModel {
    
    // MARK: - Properties
    
    var previousChosenCategory: TrackerCategory?
    
    weak var delegate: ChooseCategoryViewModelProtocol?
    
    var onCategoriesListStateChange: Binding<[TrackerCategory]>?
    var onPreviousChosenCategoryStateChange: Binding<TrackerCategory?>?
    
    private let model: TrackerCategoryStore
    
    // MARK: - Life-Cycle
    
    init() {
        model = TrackerCategoryStore()
        model.delegate = self
    }
    
    // MARK: - Methods
    
    func fetchCategories() {
        do {
            let categories = try model.getCategories()
            onCategoriesListStateChange?(categories)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    func setupPreviousChosenCategory() {
        onPreviousChosenCategoryStateChange?(previousChosenCategory)
    }
    
    func chosenCategory(_ category: TrackerCategory?) {
        onPreviousChosenCategoryStateChange?(category)
        delegate?.updateCategory(category)
    }
}

extension ChooseCategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        fetchCategories()
    }
}
