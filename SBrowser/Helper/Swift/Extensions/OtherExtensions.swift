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
