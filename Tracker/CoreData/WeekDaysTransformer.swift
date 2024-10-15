//
//  WeekDaysTransformer.swift
//  Tracker
//
//  Created by Pavel Bobkov on 30.09.2024.
//

import Foundation

@objc
final class WeekDaysTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            WeekDaysTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: WeekDaysTransformer.self))
        )
    }
}
