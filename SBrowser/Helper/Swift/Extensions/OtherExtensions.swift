//
//  OtherExtensions.swift
//  SBrowser
//
//  Created by JinXu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class Formatter: NSObject {
    class func localize(_ value: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: value), number: .none)
    }
}

extension String {
    var escapedForJavaScript: String? {
        // Wrap in an array.
        let array = [self];

        // Encode to JSON.
        if let json = try? JSONEncoder().encode(array),
            let s = String(data: json, encoding: .utf8) {

            // Then chop off the enclosing brackets. []
            return String(s[s.index(s.startIndex, offsetBy: 2) ... s.index(s.endIndex, offsetBy: -2)])
        }
        return nil
    }
}
