//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 09.10.2024.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Properties
    
    lazy var pages: [UIViewController] = {
        let firstPage = OnboardingViewController(style: .firstPage)
        let secontPage = OnboardingViewController(style: .secontPage)
        
        return [firstPage, secontPage]
    }()
    
    // MARK: - View
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let scipOnboardingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life-sycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        [pageControl, scipOnboardingButton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            scipOnboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scipOnboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scipOnboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            scipOnboardingButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: scipOnboardingButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        scipOnboardingButton.addTarget(self, action: #selector(scipOnboardingButtonTapped), for: .touchUpInside)
    }
    
    @objc private func scipOnboardingButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let tabBarController = TabBarController()
            
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.8
            sceneDelegate.window?.layer.add(transition, forKey: kCATransition)

            sceneDelegate.window?.rootViewController = tabBarController
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
