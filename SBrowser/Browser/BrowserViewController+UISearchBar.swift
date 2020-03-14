//
//  BrowserViewController+UISearchBar.swift
//  SBrowser
//
//  Created by Jin Xu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension BrowserViewController: UISearchBarDelegate {
    
    private static let secureImg = UIImage(named: "secure")
    private static let insecureImg = UIImage(named: "insecure")
    
    
    // MARK: UISearchBarDelegate
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateSearchField()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let search = self.searchBar.text
        
        DispatchQueue.main.async {
            self.liveSearchVc.hide()
            searchBar.resignFirstResponder()

            // User is shifting to a new place. Probably a good time to clear old data.
            AppDelegate.shared?.cookieJar.clearAllNonWhitelistedData()

            if let url = self.parseSearch(search) {
                self.debug("#textFieldShouldReturn url=\(url)")

                if let currentTab = self.currentTab {
                    currentTab.load(url)
                } else {
                    self.addNewTabSBrowser(url)
                }
            } else {
                self.debug("#textFieldShouldReturn search=\(String(describing: search))")

                if self.currentTab == nil {
                    self.addNewTabSBrowser()
                }

                self.currentTab?.search(for: search)
            }
        }
        
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        liveSearchVc.hide()
        updateSearchField()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDidChange()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    
    
    func updateSearchField() {
        if searchBar.isFirstResponder {
            if searchBar.textField.textAlignment == .natural {
                // Seems already set correctly. Don't mess with it, while user
                // edits it actively!
                return
            }

            searchBar.text = currentTab?.url.clean?.absoluteString

            // .unlessEditing would be such a great state, if it wouldn't show
            // while editing an empty field. Argh.
            searchBar.textField.leftViewMode = .never
            searchBar.textField.rightViewMode = .never

            searchBar.textField.textAlignment = .natural
        } else {
            searchBar.text = BrowserViewController.prettyTitle(currentTab?.url)
            searchBar.textField.leftViewMode = encryptionBt.image(for: .normal) == nil ? .never : .always
            searchBar.textField.rightViewMode = searchBar.text?.isEmpty ?? true ? .never : .always

            searchBar.textField.textAlignment = .center
        }
    }
        
    // MARK: Public Methods
    class func prettyTitle(_ url: URL?) -> String {
        guard let url = url?.clean else {
            return ""
        }

        if let host = url.host {
            return host.replacingOccurrences(of: #"^www\d*\."#, with: "", options: .regularExpression)
        }

        return url.absoluteString
    }
    
    /**
    Updates the `encryptionBt`:
    - Show a closed lock icon, when `WebViewTabSecureMode` is `.secure` or `.secureEV`.
    - Show a open lock icon, when mode is `.mixed`.
    - Show no icon, when mode is `.insecure`.
    */
    func updateEncryptionBt(_ mode: TabSBrowser.SecureMode) {
        let encryptionIcon: UIImage?

        switch mode {
        case .secure, .secureEv:
            encryptionIcon = BrowserViewController.secureImg

        case .mixed:
            encryptionIcon = BrowserViewController.insecureImg

        default:
            encryptionIcon = nil
        }
        
        if encryptionIcon == nil {
            searchBar.textField.leftView = nil
        } else {
            searchBar.textField.leftView = encryptionBt
        }

        encryptionBt.setImage(encryptionIcon, for: .normal)
        searchBar.textField.leftViewMode = searchBar.isFirstResponder || encryptionIcon == nil ? .never : .always
        
    }
    
    // MARK: Actions

    @IBAction func searchDidChange() {
        guard SettingsSBrowser.searchLive else {
            return
        }

        if parseSearch(searchBar.text) != nil {
            // That's not a search, that's a valid URL. -> Remove live search results.

            return liveSearchVc.hide()
        }

        if !liveSearchVc.searchOngoing {
            if UIDevice.current.userInterfaceIdiom == .pad {
                present(liveSearchVc, searchBar)
            }
            else {
                addChild(liveSearchVc)

                liveSearchVc.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(liveSearchVc.view)
                liveSearchVc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                liveSearchVc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                liveSearchVc.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
                liveSearchVc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }

            liveSearchVc.searchOngoing = true
        }

        liveSearchVc.update(searchBar.text, tab: currentTab)
    }
    
    
    // MARK: Private Methods

    /**
    Parse a user search.

    - parameter search: The user entry, which could be a (semi-)valid URL or a search engine query.
    - returns: A parsed (and fixed) URL or `nil`, in which case you should treat the string as a search engine query.
    */
    private func parseSearch(_ search: String?) -> URL? {
        // Must not be empty, must not be the explicit blank page.
        if let search = search,
            !search.isEmpty {

            // blank page, return that.
            if search.caseInsensitiveCompare(URL.blank.absoluteString) == .orderedSame {
                return URL.blank
            }

            // If credits page, return that.
            if search.caseInsensitiveCompare(URL.aboutSBrowser.absoluteString) == .orderedSame {
                return URL.aboutSBrowser
            }

            if search.range(of: #"\s+"#, options: .regularExpression) != nil
                || !search.contains(".") {
                // Search contains spaces or contains no dots. That's really a search!
                return nil
            }

            // We rely on URLComponents parsing style! *Don't* change to URL!
            if let urlc = URLComponents(string: search) {
                let scheme = urlc.scheme?.lowercased() ?? ""

                if scheme.isEmpty {
                    // Set missing scheme to HTTP.
                    return URL(string: "http://\(search)")
                }

                if scheme != "about" && scheme != "file" {
                    if urlc.host?.isEmpty ?? true
                        && urlc.path.range(of: #"^\d+"#, options: .regularExpression) != nil {

                        // A scheme, no host, path begins with numbers. Seems like "example.com:1234" was parsed wrongly.
                        return URL(string: "http://\(search)")
                    }

                    // User has simply entered a valid URL?!?
                    return urlc.url
                }

                // Someone wants to try something here. No way.
            }

            // Unparsable.
        }

        //  Return start page.
        return URL.start
    }
    
        
}
