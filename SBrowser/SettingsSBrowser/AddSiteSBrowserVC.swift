//
//  AddSiteSBrowserVC.swift
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka

class AddSiteSBrowserVC: SBFixedFormVC {

    private var hostRow = TextRow() {
            $0.title = NSLocalizedString("Host", comment: "Option title")
            $0.placeholder = "example.com"
            $0.cell.textField.autocorrectionType = .no
            $0.cell.textField.autocapitalizationType = .none
            $0.cell.textField.keyboardType = .URL
            $0.cell.textField.textContentType = .URL
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            navigationItem.title = NSLocalizedString("Add Site", comment: "Scene title")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add, target: self, action: #selector(add))
            navigationItem.rightBarButtonItem?.isEnabled = false

            // Prefill with current tab's host.
            if let info = AddSiteSBrowserVC.getCurrentTabInfo() {
                hostRow.value = info.url.host ?? info.url.path
                navigationItem.rightBarButtonItem?.isEnabled = true
            }

            form
            +++ hostRow
            .onChange { row in
                self.navigationItem.rightBarButtonItem?.isEnabled = row.value != nil
            }
        }


        // MARK: Actions

        @objc private func add() {
            if let host = hostRow.value {

                // Create full host settings for this host, if not yet available.
                if !HostSettingsSBrowser.has(host) {
                    HostSettingsSBrowser(for: host, withDefaults: true).save().store()
                }

                if var vcs = navigationController?.viewControllers {
                    vcs.removeLast()

                    let vc = SBrowserSecurityVC()
                    vc.host = host
                    vcs.append(vc)

                    navigationController?.setViewControllers(vcs, animated: true)
                }
            }
        }

        /**
        Evaluates the current tab, if it contains a valid URL.

        - returns: nil if current tab contains no valid URL, or the URL and possibly the tab title.
        */
        public class func getCurrentTabInfo() -> (url: URL, title: String?)? {
            if let tab = sharedBrowserVC?.currentTab,
                let scheme = tab.url.scheme?.lowercased() {

                if scheme == "http" || scheme == "https" {
                    return (url: tab.url, title: tab.title)
                }
            }

            return nil
        }
    }
