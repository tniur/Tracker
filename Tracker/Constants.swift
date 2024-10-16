//
//  Constants.swift
//  Tracker
//
//  Created by Pavel Bobkov on 25.09.2024.
//

import UIKit

enum Constants {
    static let timetableCategory = [NSLocalizedString("monday", comment: "Monday"),
                                    NSLocalizedString("tuesday", comment: "Tuesday"),
                                    NSLocalizedString("wednesday", comment: "Wednesday"),
                                    NSLocalizedString("thursday", comment: "Thursday"),
                                    NSLocalizedString("friday", comment: "Friday"),
                                    NSLocalizedString("saturday", comment: "Saturday"),
                                    NSLocalizedString("sunday", comment: "Sunday")]
    static let trackerEmoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    static let trackerColours: [UIColor] = [.ypSelection1, .ypSelection2, .ypSelection3, .ypSelection4, .ypSelection5, .ypSelection6, .ypSelection7, .ypSelection8, .ypSelection9, .ypSelection10, .ypSelection11, .ypSelection12, .ypSelection13, .ypSelection14, .ypSelection15, .ypSelection16, .ypSelection17, .ypSelection18]
}
