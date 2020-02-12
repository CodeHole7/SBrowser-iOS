//
//  SBTabSecurity.swift
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

@objcMembers
class SBTabSecurity: NSObject {

    enum Level: String, CustomStringConvertible {

        case alwaysRemember = "always_remember"
        case forgetOnShutdown = "forget_on_shutdown"
        case clearOnBackground = "clear_on_background"

        var description: String {
            switch self {
            case .alwaysRemember:
                return NSLocalizedString("Remember Tabs", comment: "TabSBrowser security level")

            case .forgetOnShutdown:
                return NSLocalizedString("Forget at Shutdown", comment: "TabSBrowser security level")

            default:
                return NSLocalizedString("Forget in Background", comment: "TabSBrowser security level")
            }
        }
    }

    class var isClearOnBackground: Bool {
        return SettingsSBrowser.tabSecurity  == .clearOnBackground
    }

    /**
    Handle tab privacy
    */
    class func handleBackgrounding() {
        let security = SettingsSBrowser.tabSecurity
        let controller = sharedBrowserVC
        let cookieJar = AppDelegate.shared?.cookieJar
        let ocspCache = AppDelegate.shared?.certificateAuthentication

        if security == .clearOnBackground {
            controller?.removeAllTabs()
        }
        else {
            cookieJar?.clearAllOldNonWhitelistedData()
            ocspCache?.persist()
        }

        if security == .alwaysRemember {
            // Ignore special URLs, as these could get us into trouble after app updates.
            SettingsSBrowser.openTabs = controller?.tabs.map({ $0.url }).filter({ !$0.isSpecial })

            print("[\(String(describing: self))] save open tabs=\(String(describing: SettingsSBrowser.openTabs))")
        }
        else {
            print("[\(String(describing: self))] clear saved open tab urls")
            SettingsSBrowser.openTabs = nil
        }
    }

    class func restore() {
        if SettingsSBrowser.tabSecurity  == .alwaysRemember,
            let controller = sharedBrowserVC {

            for url in SettingsSBrowser.openTabs ?? [] {
                // Ignore special URLs, as these could get us into trouble after app updates.
                if !url.isSpecial {
                    print("[\(String(describing: self))] restore tab with url=\(url)")

                    controller.addNewTabSBrowser(url, transition: .notAnimated)
                }
            }
        }
        else {
            print("[\(String(describing: self))] clear saved open tab urls")
            SettingsSBrowser.openTabs = nil
        }
    }
}
