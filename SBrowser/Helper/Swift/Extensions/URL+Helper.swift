//
//  URL+Helper.swift
//  SBrowser
//
//  Created by JinXu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension URL {

    static let blank = URL(string: "about:blank")!

    static let aboutSBrowser = URL(string: "about:SBrowser")!
    static let credits = Bundle.main.url(forResource: "credits", withExtension: "html")!
    static let start = Bundle.main.url(forResource: "newTab", withExtension: "html")!

    //static let start = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!.appendingPathComponent("start.html")

    var withFixedScheme: URL? {
        switch scheme?.lowercased() {
        case "shttp":
            var urlc = URLComponents(url: self, resolvingAgainstBaseURL: true)
            urlc?.scheme = "http"

            return urlc?.url

        case "shttps":
            var urlc = URLComponents(url: self, resolvingAgainstBaseURL: true)
            urlc?.scheme = "https"

            return urlc?.url

        default:
            return self
        }
    }

    var real: URL {
        switch self {
        case URL.aboutSBrowser:
            return URL.credits
        default:
            return self
        }
    }

    var clean: URL? {
        switch self {
        case URL.credits:
            return URL.aboutSBrowser

        case URL.start:
            return nil

        default:
            return self
        }
    }

    var isSpecial: Bool {
        switch self {
        case URL.blank, URL.aboutSBrowser, URL.credits, URL.start:
            return true

        default:
            return false
        }
    }
}

@objc
extension NSURL {

    var withFixedScheme: NSURL? {
        return (self as URL).withFixedScheme as NSURL?
    }
}
