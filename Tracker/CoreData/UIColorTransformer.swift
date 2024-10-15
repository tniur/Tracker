//
//  UIColorTransformer.swift
//  Tracker
//
//  Created by Pavel Bobkov on 16.10.2024.
//

import UIKit

@objc(UIColorTransformer)
class UIColorTransformer: NSSecureUnarchiveFromDataTransformer {

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    static func register() {
        let transformerName = NSValueTransformerName(rawValue: String(describing: UIColorTransformer.self))
        let transformer = UIColorTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: transformerName)
    }
}
