//
//  SBSecurityPopUpViewController.swift
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBSecurityPopUpViewController: UIViewController, UIPopoverPresentationControllerDelegate,
UITableViewDataSource, UITableViewDelegate {

    var host: String?

        @IBOutlet weak var headerLb: UILabel! {
            didSet {
                headerLb.text = host != nil
                    ? NSLocalizedString("Security Level for This Site", comment: "")
                    : NSLocalizedString("Default Security", comment: "")
            }
        }

        @IBOutlet weak var tableView: UITableView!

        @IBOutlet weak var customizeBt: UIButton! {
            didSet {
                customizeBt.setTitle("Customize", for: .normal)
            }
        }

        @IBOutlet weak var learnMoreBt: UIButton! {
            didSet {
                learnMoreBt.setTitle("Learn More", for: .normal)
                learnMoreBt.isHidden = true // Disabled, as no content, yet.
            }
        }


        override var preferredContentSize: CGSize {
            get {
                return CGSize(width: 300, height: 320 + (current == .custom ? SBSecurityLevelCell.height : 0))
            }
            set {
                // Ignore.
            }
        }

        private var presets: [SecurityPreset] = [.insecure, .medium, .secure]

        private lazy var current = SecurityPreset(HostSettingsSBrowser.for(host))

        private lazy var hostSettings: HostSettingsSBrowser = {
            guard let host = host, !host.isEmpty else {
                return HostSettingsSBrowser.forDefault()
            }

            return HostSettingsSBrowser.for(host)
        }()

        private var changeObserver: Any?

        override func viewDidLoad() {
            super.viewDidLoad()

            if current == .custom {
                presets.append(.custom)
            }

            tableView.register(SBSecurityLevelCell.nib, forCellReuseIdentifier: SBSecurityLevelCell.reuseId)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if let row = presets.firstIndex(of: current) {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: animated, scrollPosition: .none)
            }

            // Dismiss ourselves if the user changed something in SBrowserSecurityVC.
            changeObserver = NotificationCenter.default.addObserver(
                forName: .hostSettingsChanged, object: nil, queue: .main)
            { notification in
                let host = notification.object as? String

                // Hide on default changes and specific changes for this host.
                if (host == nil || host == self.host)
                    && self.current != SecurityPreset(HostSettingsSBrowser.for(host)) {

                    self.dismiss(animated: true)
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if let changeObserver = changeObserver {
                NotificationCenter.default.removeObserver(changeObserver)
                self.changeObserver = nil
            }
        }


        // MARK: UITableViewDataSource

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return presets.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: SBSecurityLevelCell.reuseId, for: indexPath)
                as! SBSecurityLevelCell

            return cell.set(presets[indexPath.row])
        }


        // MARK: UITableViewDelegate

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return SBSecurityLevelCell.height
        }

        func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            // Don't do anything when the already selected row was selected again.
            if let selected = tableView.indexPathForSelectedRow?.row,
                indexPath.row == selected {
                return indexPath
            }

            current = presets[indexPath.row]

            hostSettings.contentPolicy = current.values?.csp ?? .strict
            hostSettings.webRtc = current.values?.webRtc ?? false
            hostSettings.mixedMode = current.values?.mixedMode ?? false

            // Trigger creation, save and store of HostSettingsSBrowser for this host.
            hostSettings.save().store()

            dismiss(animated: true)

            return indexPath
        }


        // MARK: UIPopoverPresentationControllerDelegate

        public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }


        // MARK: Actions

        @IBAction func customize() {
            // Trigger creation, save and store of HostSettingsSBrowser for this host.
            hostSettings.save().store()

            let vc = SBrowserSecurityVC()
            vc.host = host

            present(UINavigationController(rootViewController: vc))
        }

        @IBAction func learnMore() {
            // TODO
        }
    }
