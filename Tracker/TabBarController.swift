//
//  TabBarController.swift
//  Tracker
//
//  Created by Pavel Bobkov on 23.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackersViewNavigationController = UINavigationController(rootViewController: trackersViewController)
        let statisticsViewNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: "Trackers"),
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics", comment: "Statistics"),
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor { (traits: UITraitCollection) -> UIColor in
            return traits.userInterfaceStyle == .light ? .ypLightGray : .ypBlack
        }.cgColor
        
        self.viewControllers = [trackersViewNavigationController, statisticsViewNavigationController]
    }
    
    private func updateTabBarBorderColor(for traits: UITraitCollection) {
            self.tabBar.layer.borderColor = UIColor { (traits: UITraitCollection) -> UIColor in
                return traits.userInterfaceStyle == .light ? .ypLightGray : .ypBlack
            }.cgColor
        }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTabBarBorderColor(for: traitCollection)
        }
    }
}
