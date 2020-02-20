//
//  SBSettingsVC.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka

class SBSettingsVC: SBFixedFormVC {
    
    private let defaultSecurityRow = LabelRow() {
        $0.title = NSLocalizedString("Default Security", comment: "Option title")
        $0.cell.textLabel?.numberOfLines = 0
        $0.cell.accessoryType = .disclosureIndicator
        $0.cell.selectionStyle = .default
    }
    
    private let historyRow = LabelRow() {
        $0.title = NSLocalizedString("History", comment: "Option title")
        $0.cell.textLabel?.numberOfLines = 0
        $0.cell.accessoryType = .disclosureIndicator
        $0.cell.selectionStyle = .default
    }
    
    private let homepageRow = LabelRow() {
        $0.title = NSLocalizedString("Homepage", comment: "Option title")
        $0.cell.textLabel?.numberOfLines = 0
        $0.cell.accessoryType = .disclosureIndicator
        $0.cell.selectionStyle = .default
    }
    
    
    @objc
    class func instantiate() -> UINavigationController {
        return UINavigationController(rootViewController: self.init())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(dismsiss_))
        navigationItem.title = NSLocalizedString("Settings", comment: "Scene title")
        
        form
            
            
            +++ Section(header: NSLocalizedString("GENERAL", comment: "Section header"),
                                   footer: NSLocalizedString("",
                                                             comment: ""))
            
           <<< homepageRow
                .onCellSelection({ (_, _) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let HomePageSettingVC = storyboard.instantiateViewController(withIdentifier: "SBHomePageSettingVC")
                    self.navigationController?.pushViewController(HomePageSettingVC, animated: true)
                   // self.present(SBHomePageSettingVC.instantiate(), nil)
                })
            
           <<< historyRow
                .onCellSelection({ (_, _) in
//                    let navController = SBHistoryVC.instantiate()
//                    (navController.viewControllers.first as? SBHistoryVC)?.sbSettingVC = self
//                    self.present(navController, nil)
                    let historyvc = SBHistoryVC()
                    historyvc.ReloadData()
                    historyvc.sbSettingVC = self
                    self.navigationController?.pushViewController(historyvc, animated: true)
                })
            
           <<< defaultSecurityRow
                .onCellSelection { _, _ in
                    self.navigationController?.pushViewController(
                        SBSecurityVC(), animated: true)
            }
            
            +++ Section(header: NSLocalizedString("Search", comment: "Section header"),
                        footer: NSLocalizedString("When disabled, all text entered in search bar will be sent to the search engine unless it starts with \"http\".",
                                                  comment: "Explanation in section footer"))
            
            <<< PushRow<String>() {
                $0.title = NSLocalizedString("Search Engine", comment: "Option title")
                $0.selectorTitle = $0.title
                $0.options = SettingsSBrowser.allSearchEngineNames
                $0.value = SettingsSBrowser.searchEngineName
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.searchEngineName = value
                }
            }
            
            <<< SwitchRow() {
                $0.title = NSLocalizedString("Auto-Complete Search Results", comment: "Option title")
                $0.value = SettingsSBrowser.searchLive
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.searchLive = value
                }
            }
            
            <<< SwitchRow() {
                $0.title = NSLocalizedString("Stop Auto-Complete at First Dot", comment: "Option title")
                $0.value = SettingsSBrowser.searchLiveStopDot
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.searchLiveStopDot = value
                }
            }
            
            +++ Section(header: NSLocalizedString("Privacy & Security", comment: "Section header"),
                        footer: NSLocalizedString("Choose how long app remembers open tabs.", comment: "Explanation in section footer"))
            /*
            <<< LabelRow() {
                $0.title = NSLocalizedString("Custom Site Security", comment: "Option label")
                $0.cell.textLabel?.numberOfLines = 0
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .default
            }
            .onCellSelection { _, _ in
                self.navigationController?.pushViewController(SBCustomSiteVC(), animated: true)
            }
            
            <<< SwitchRow() {
                $0.title = NSLocalizedString("Send Do-Not-Track Header", comment: "Option title")
                $0.value = SettingsSBrowser.sendDnt
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.sendDnt = value
                }
            }
            */
            <<< LabelRow() {
                $0.title = NSLocalizedString("Cookies and Local Storage", comment: "Option title")
                $0.cell.textLabel?.numberOfLines = 0
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .default
            }
            .onCellSelection { _, _ in
                self.navigationController?.pushViewController(
                    SBStorageFirstVC(), animated: true)
            }
            //ps
            <<< LabelRow() {
                $0.title = NSLocalizedString("Profiles", comment: "Option title")
            //    $0.selectorTitle = $0.title

                
                $0.cell.accessoryType = .disclosureIndicator
              //  $0.cell.selectionStyle = .default
                $0.cell.textLabel?.numberOfLines = 0
            }

            .onCellSelection { _, _ in
                self.navigationController?.pushViewController(
                    SBProfilesVC(), animated: true)
            }
            //ps
            <<< PushRow<SettingsSBrowser.TlsVersion>() {
                $0.title = NSLocalizedString("TLS Version", comment: "Option title")
                $0.selectorTitle = $0.title
                $0.options = [SettingsSBrowser.TlsVersion.tls13,
                              SettingsSBrowser.TlsVersion.tls12,
                              SettingsSBrowser.TlsVersion.tls10]
                
                $0.value = SettingsSBrowser.tlsVersion
                
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onPresent { vc, selectorVc in
                // This is just to trigger the usage of #sectionFooterTitleForKey
                selectorVc.sectionKeyForValue = { value in
                    return NSLocalizedString("TLS Version", comment: "Option title")
                }
                
                selectorVc.sectionFooterTitleForKey = { key in
                    return NSLocalizedString("Minimum version of TLS required for hosts to negotiate HTTPS connections.",
                                             comment: "Option description")
                }
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.tlsVersion = value
                }
            }
            
            <<< PushRow<SBTabSecurity.Level>() {
                $0.title = NSLocalizedString("Tab Security", comment: "Option title")
                $0.selectorTitle = $0.title
                $0.options = [SBTabSecurity.Level.alwaysRemember,
                              SBTabSecurity.Level.forgetOnShutdown,
                              SBTabSecurity.Level.clearOnBackground]
                
                $0.value = SettingsSBrowser.tabSecurity
                
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.tabSecurity = value
                }
            }
            
            +++ Section(header: NSLocalizedString("Miscellaneous", comment: "Section header"),
                        footer: NSLocalizedString("Changing this option requires restarting the app.",
                                                  comment: "Option explanation"))
            /*
            <<< LabelRow() {
                $0.title = NSLocalizedString("URL Blocker", comment: "Option label")
                $0.cell.textLabel?.numberOfLines = 0
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .default
            }
            .onCellSelection { _, _ in
                self.navigationController?.pushViewController(URLBlockerRuleController(), animated: true)
            }
            
            <<< LabelRow() {
                $0.title = NSLocalizedString("HTTPS Everywhere", comment: "Option label")
                $0.cell.textLabel?.numberOfLines = 0
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .default
            }
            .onCellSelection { _, _ in
                self.navigationController?.pushViewController(HTTPSEverywhereRuleController(), animated: true)
            }
            */
            <<< SwitchRow() {
                $0.title = NSLocalizedString("Mute Audio with Mute Switch", comment: "Option title")
                $0.value = SettingsSBrowser.muteWithSwitch
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.muteWithSwitch = value
                }
            }
            /*
            <<< SwitchRow() {
                $0.title = NSLocalizedString("Allow 3rd-Party Keyboards", comment: "Option title")
                $0.value = SettingsSBrowser.thirdPartyKeyboards
                $0.cell.switchControl.onTintColor = .accent
                $0.cell.textLabel?.numberOfLines = 0
            }
            .onChange { row in
                if let value = row.value {
                    SettingsSBrowser.thirdPartyKeyboards = value
                }
        }
        */
        
        let section = Section(header: NSLocalizedString("Support", comment: "Section header"),
                              footer: String(
                                format: NSLocalizedString("Version %@", comment: "Version info at end of scene"),
                                Bundle.main.version))
        
        form
            +++ section
            <<< ButtonRow() {
                $0.title = NSLocalizedString("Report a Bug", comment: "Button title")
                $0.cell.textLabel?.numberOfLines = 0
            }
            .cellUpdate { cell, _ in
                cell.textLabel?.textAlignment = .natural
            }
            .onCellSelection { _, _ in
                sharedBrowserVC?.addNewTabSBrowser(
                    URL(string: "https://sbrowser.com/issues"),
                    transition: .notAnimated)
                
                self.dismsiss_()
        }
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id*********"),
            UIApplication.shared.canOpenURL(url) {
            
            section
                <<< ButtonRow() {
                    $0.title = NSLocalizedString("Rate on App Store", comment: "Button title")
                    $0.cell.textLabel?.numberOfLines = 0
                }
                .cellUpdate { cell, _ in
                    cell.textLabel?.textAlignment = .natural
                }
                .onCellSelection { _, _ in
                    UIApplication.shared.open(url, options: [:])
            }
        }
        
        section
            
            <<< ButtonRow() {
                $0.title = NSLocalizedString("About", comment: "Button title")
                $0.cell.textLabel?.numberOfLines = 0
            }
            .cellUpdate { cell, _ in
                cell.textLabel?.textAlignment = .natural
            }
            .onCellSelection { _, _ in
                sharedBrowserVC?.addNewTabSBrowser(URL.aboutSBrowser,
                                                   transition: .notAnimated)
                
                self.dismsiss_()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        defaultSecurityRow.value = SecurityPreset(HostSettingsSBrowser.forDefault()).description
        defaultSecurityRow.updateCell()
    }
    
    @objc private func dismsiss_() {
        navigationController?.dismiss(animated: true)
    }
}
