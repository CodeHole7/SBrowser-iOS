//
//  SecurityVC.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka
import SDCAlertView

class SBSecurityVC: SBFixedFormVC {

    var host: String?

        private lazy var hostSettings = host?.isEmpty ?? true
            ? HostSettingsSBrowser.forDefault()
            : HostSettingsSBrowser.for(host)

        private let securityPresetsRow = SBSecurityPresetsRow()

        private let contentPolicyRow = PushRow<HostSettingsSBrowser.ContentPolicy>() {
            $0.title = NSLocalizedString("Content Policy", comment: "Option title")
            $0.selectorTitle = $0.title
            $0.options = [.open, .blockXhr, .strict]
            $0.cell.textLabel?.numberOfLines = 0
        }

        private let webRtcRow = SwitchRow() {
            $0.title = NSLocalizedString("WebRTC", comment: "Option title")
            $0.cell.switchControl.onTintColor = .accent
            $0.cell.textLabel?.numberOfLines = 0
        }

        private let mixedModeRow = SwitchRow() {
            $0.title = NSLocalizedString("Mixed-mode Resources", comment: "Option title")
            $0.cell.switchControl.onTintColor = .accent
            $0.cell.textLabel?.numberOfLines = 0
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            navigationItem.title = host ?? NSLocalizedString("Default Security", comment: "Scene title")

            // We're the root here! Provide a means to exit.
            if navigationController?.viewControllers.first == self {
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .done, target: self,
                    action: #selector(_dismiss))
            }

            securityPresetsRow.value = SecurityPreset(hostSettings)
            contentPolicyRow.value = hostSettings.contentPolicy
            webRtcRow.value = hostSettings.webRtc
            mixedModeRow.value = hostSettings.mixedMode

            form
            +++ (host != nil ? Section() : Section("to be replaced in #willDisplayHeaderView to avoid capitalization"))

            <<< securityPresetsRow
            .onChange { row in
                // Only change other settings, if a non-custom preset was chosen.
                // Do nothing, if it was unselected.
                if let values = row.value?.values {

                    // Force-set this, because #onChange callbacks are only called,
                    // when values actually change. So this might lead to a host
                    // still being configured for default values, although these should
                    // be set hard.
                    self.hostSettings.contentPolicy = values.csp
                    self.hostSettings.webRtc = values.webRtc
                    self.hostSettings.mixedMode = values.mixedMode

                    self.contentPolicyRow.value = values.csp
                    self.webRtcRow.value = values.webRtc
                    self.mixedModeRow.value = values.mixedMode

                    self.contentPolicyRow.updateCell()
                    self.webRtcRow.updateCell()
                    self.mixedModeRow.updateCell()
                }
            }

            +++ Section(footer: NSLocalizedString("Handle tapping on links in a non-standard way to avoid possibly opening external applications.",
                                                  comment: "Option description"))

            <<< contentPolicyRow
            .onPresent { vc, selectorVc in
                // This is just to trigger the usage of #sectionFooterTitleForKey
                selectorVc.sectionKeyForValue = { value in
                    return NSLocalizedString("Content Policy", comment: "Option title")
                }

                selectorVc.sectionFooterTitleForKey = { key in
                    return NSLocalizedString("Restrictions on resources loaded from web pages.",
                                             comment: "Option description")
                }
            }
            .onChange { row in
                let csp = row.value ?? .strict
                var webRtc = self.hostSettings.webRtc

                // Cannot have WebRTC while blocking everything besides images and styles.
                // So need to restriction there, too.
                if csp == .strict && webRtc {
                    webRtc = false
                }

                self.alertBeforeChange(csp, webRtc, self.hostSettings.mixedMode)
            }

            <<< SwitchRow() {
                $0.title = NSLocalizedString("Universal Link Protection", comment: "Option title")
                $0.value = hostSettings.universalLinkProtection
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                self.hostSettings.universalLinkProtection = row.value ?? false
            }

            +++ Section(footer: NSLocalizedString("Allow hosts to access WebRTC functions.",
                                                  comment: "Option description"))

            <<< webRtcRow
            .onChange { row in
                let webRtc = row.value ?? false
                var csp = self.hostSettings.contentPolicy

                // Cannot have WebRTC while blocking everything besides images and styles.
                // So need to lift restrictions there, too.
                if webRtc && csp == .strict {
                    csp = .blockXhr
                }

                self.alertBeforeChange(csp, webRtc, self.hostSettings.mixedMode)
            }

            +++ Section(footer: NSLocalizedString("Allow HTTPS hosts to load page resources from non-HTTPS hosts. (Useful for RSS readers and other aggregators.)",
                                                  comment: "Option description"))

            <<< mixedModeRow
            .onChange { row in
                self.alertBeforeChange(self.hostSettings.contentPolicy,
                                       self.hostSettings.webRtc, row.value ?? false)
            }

            +++ Section(header: NSLocalizedString("Privacy", comment: "Section title"),
                        footer: NSLocalizedString("Allow hosts to permanently store cookies and local storage databases.", comment: "Option description"))

            <<< SwitchRow() {
                $0.title = NSLocalizedString("Allow Persistent Cookies", comment: "Option title")
                $0.value = hostSettings.whitelistCookies
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                self.hostSettings.whitelistCookies = row.value ?? false
            }

            let section = Section(header: NSLocalizedString("Other", comment: "Section title"),
                                  footer: NSLocalizedString("Custom user-agent string, or blank to use the default.",
                                                            comment: "Option description"))

            form
            +++ section

            if hostSettings.ignoreTlsErrors {
                section
                <<< SwitchRow() {
                    $0.title = NSLocalizedString("Ignore TLS Errors", comment: "Option title")
                    $0.value = hostSettings.ignoreTlsErrors
                    $0.cell.switchControl.onTintColor = .accent
                    $0.cell.textLabel?.numberOfLines = 0
                }
                .onChange { row in
                    self.hostSettings.ignoreTlsErrors = false

                    row.cell.switchControl.isEnabled = false
                }
            }

            section
            <<< TextRow() {
                $0.title = NSLocalizedString("User Agent", comment: "Option title")
                $0.value = hostSettings.userAgent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange {row in
                self.hostSettings.userAgent = row.value ?? ""
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            hostSettings.save().store()
        }


        // MARK: UITableViewDelegate

        /**
        Workaround to avoid capitalization of header.
        */
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            if section == 0,
                let header = view as? UITableViewHeaderFooterView {

                header.textLabel?.text = String(format:
                    NSLocalizedString("This is your default security setting for every website you visit in %@.",
                                      comment: "Scene description, placeholder will contain app name"),
                                                Bundle.main.displayName)
            }
        }


        // MARK: Private Methods

        @objc
        private func _dismiss() {
            dismiss(animated: true)
        }

        private var calledTwice = false

        private func alertBeforeChange(_ csp: HostSettingsSBrowser.ContentPolicy, _ webRtc: Bool, _ mixedMode: Bool) {

            let preset = SecurityPreset(csp, webRtc, mixedMode)

            let okHandler = {
                self.hostSettings.contentPolicy = csp
                self.hostSettings.webRtc = webRtc
                self.hostSettings.mixedMode = mixedMode

                // Could have been modified by webRtcRow.
                if csp != self.contentPolicyRow.value {
                    self.calledTwice = true
                    self.contentPolicyRow.value = csp
                    self.contentPolicyRow.updateCell()
                }

                // Could have been modified by contentPolicyRow.
                if webRtc != self.webRtcRow.value {
                    self.calledTwice = true
                    self.webRtcRow.value = webRtc
                    self.webRtcRow.updateCell()
                }

                self.securityPresetsRow.value = SecurityPreset(self.hostSettings)
                self.securityPresetsRow.updateCell()
            }

            if !calledTwice && preset == .custom && securityPresetsRow.value != .custom {
                let cancelHandler = {
                    self.contentPolicyRow.value = self.hostSettings.contentPolicy
                    self.webRtcRow.value = self.hostSettings.webRtc
                    self.mixedModeRow.value = self.hostSettings.mixedMode

                    self.contentPolicyRow.updateCell()
                    self.webRtcRow.updateCell()
                    self.mixedModeRow.updateCell()

                    self.calledTwice = false
                }

                let alert = AlertController(title: nil, message: nil)
                let cv = alert.contentView

                let illustration = UIImageView(image: UIImage(named: "custom-shield"))
                illustration.translatesAutoresizingMaskIntoConstraints = false
                cv.addSubview(illustration)
                illustration.topAnchor.constraint(equalTo: cv.topAnchor, constant: -16).isActive = true
                illustration.widthAnchor.constraint(equalToConstant: 24).isActive = true
                illustration.heightAnchor.constraint(equalToConstant: 30).isActive = true
                illustration.centerXAnchor.constraint(equalTo: cv.centerXAnchor).isActive = true

                let message = UILabel()
                message.translatesAutoresizingMaskIntoConstraints = false
                message.text = NSLocalizedString("By editing this setting, you have created a custom security setting.", comment: "")
                message.font = .boldSystemFont(ofSize: 16)
                message.textAlignment = .center
                message.numberOfLines = 0
                cv.addSubview(message)
                message.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: 8).isActive = true
                message.leftAnchor.constraint(equalTo: cv.leftAnchor).isActive = true
                message.rightAnchor.constraint(equalTo: cv.rightAnchor).isActive = true
                message.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -16).isActive = true

                alert.addAction(AlertAction(
                    title: NSLocalizedString("Cancel", comment: ""), style: .preferred,
                    handler: { _ in cancelHandler() }))
                alert.addAction(AlertAction(
                    title: NSLocalizedString("OK", comment: ""), style: .normal,
                    handler: { _ in okHandler() }))

                present(alert)
            }
            else {
                okHandler()
                calledTwice = false
            }
        }
    }
