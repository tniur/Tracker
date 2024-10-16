//
//  OnboardingPageStyle.swift
//  Tracker
//
//  Created by Pavel Bobkov on 09.10.2024.
//

import UIKit

enum OnboardingPageStyle {
    case firstPage
    case secontPage
    
    var image: UIImage? {
        switch self {
        case .firstPage: return UIImage(named: "onboarding_first_page")
        case .secontPage: return UIImage(named: "onboarding_second_page")
        }
    }
    
    var title: String? {
        switch self {
        case .firstPage: return NSLocalizedString("onboardingText.first", comment: "Onboarding text")
        case .secontPage: return NSLocalizedString("onboardingText.second", comment: "Onboarding text")
        }
    }
}
