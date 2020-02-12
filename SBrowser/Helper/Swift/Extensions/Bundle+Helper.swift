//
//  Bundle+Helper.swift
//  SBrowser
//
//  Created by Jin Xu on 23/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

import Foundation

public extension Bundle {

    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
            ?? ""
    }

    var version: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "unknown"
    }
}
