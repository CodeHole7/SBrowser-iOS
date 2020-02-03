//
//  TabSBrowser+WKNavigationDelegate.swift
//  SBrowser
//
//  Created by JinXu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension TabSBrowser: WKNavigationDelegate {
    
    /**
    Must match injected.js
    */
    private static let validParams = ["hash", "hostname", "href", "pathname",
                                      "port", "protocol", "search", "username",
                                      "password", "origin"]

    private static let universalLinksWorkaroundKey = "yayprivacy"
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        /*
        
        let request = navigationAction.request
        if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .formSubmitted {
            decisionHandler(.cancel)
            return
        }
        */
        
        guard let url = navigationAction.request.url else {
            return decisionHandler(WKNavigationActionPolicy.cancel)
        }
        
        if url.scheme?.lowercased() == "endlessipc" {
            return handleIpc(url, navigationAction.navigationType) ? decisionHandler(WKNavigationActionPolicy.allow) : decisionHandler(WKNavigationActionPolicy.cancel)
        }
        
        
        // Try to prevent universal links from triggering by refusing the initial request and starting a new one.
        let iframe = url.absoluteString != navigationAction.request.mainDocumentURL?.absoluteString

        if HostSettingsSBrowser.for(url.host).universalLinkProtection {
            if iframe && navigationAction.navigationType != .linkActivated //.linkClicked//vishnu
            {
                print("[Tab \(index)] not doing universal link workaround for iframe \(url).")
            } else if navigationAction.navigationType == .backForward {
                print("[Tab \(index)] not doing universal link workaround for back/forward navigation to \(url).")
            } else if navigationAction.navigationType == .formSubmitted {
                print("[Tab \(index)] not doing universal link workaround for form submission to \(url).")
            } else if (url.scheme?.lowercased().hasPrefix("http") ?? false) && (URLProtocol.property(forKey: TabSBrowser.universalLinksWorkaroundKey, in: navigationAction.request) == nil) {
                if let tr = navigationAction.request as? NSMutableURLRequest {
                    URLProtocol.setProperty(true, forKey: TabSBrowser.universalLinksWorkaroundKey, in: tr)

                    print("[Tab \(index)] doing universal link workaround for \(url).")

                    load(tr as URLRequest)

                    return decisionHandler(WKNavigationActionPolicy.cancel)
                }
            }
        } else {
            print("[Tab \(index)] not doing universal link workaround for \(url) due to HostSettings.")
        }

        if !iframe {
            reset(navigationAction.request.mainDocumentURL)
        }
        cancelDownload()
                
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        /*
        let request = navigationAction.request
        if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .formSubmitted {
            decisionHandler(WKNavigationActionPolicy.cancel, preferences)
            return
        }
        */
        
        
        guard let url = navigationAction.request.url else {
            return decisionHandler(WKNavigationActionPolicy.cancel, preferences)
        }
        
        if url.scheme?.lowercased() == "endlessipc" {
            return handleIpc(url, navigationAction.navigationType) ? decisionHandler(WKNavigationActionPolicy.allow, preferences) : decisionHandler(WKNavigationActionPolicy.cancel, preferences)
        }
        
        
        
        // Try to prevent universal links from triggering by refusing the initial request and starting a new one.
        let iframe = url.absoluteString != navigationAction.request.mainDocumentURL?.absoluteString
        
        if !iframe {
            reset(navigationAction.request.mainDocumentURL)
        }

        if HostSettingsSBrowser.for(url.host).universalLinkProtection {
            if iframe && navigationAction.navigationType != .linkActivated //.linkClicked//vishnu
            {
                print("[Tab \(index)] not doing universal link workaround for iframe \(url).")
            } else if navigationAction.navigationType == .backForward {
                print("[Tab \(index)] not doing universal link workaround for back/forward navigation to \(url).")
            } else if navigationAction.navigationType == .formSubmitted {
                print("[Tab \(index)] not doing universal link workaround for form submission to \(url).")
            } else if (url.scheme?.lowercased().hasPrefix("http") ?? false) && (URLProtocol.property(forKey: TabSBrowser.universalLinksWorkaroundKey, in: navigationAction.request) == nil) {
                if let tr = navigationAction.request as? NSMutableURLRequest {
                    URLProtocol.setProperty(true, forKey: TabSBrowser.universalLinksWorkaroundKey, in: tr)

                    print("[Tab \(index)] doing universal link workaround for \(url).")

                    load(tr as URLRequest)

                    return decisionHandler(WKNavigationActionPolicy.cancel, preferences)
                }
            }
        } else {
            print("[Tab \(index)] not doing universal link workaround for \(url) due to HostSettings.")
        }

        
        cancelDownload()
        
        decisionHandler(WKNavigationActionPolicy.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progress = 0.1
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        progress = 1
        
        // If we have JavaScript blocked, these will be empty.
        var finalUrl = stringByEvaluatingJavaScript(from: "window.location.href")

        if finalUrl?.isEmpty ?? true {
            //finalUrl = webView.request?.mainDocumentURL?.absoluteString//vishnu
            finalUrl = webView.url?.absoluteString
        }

        url = URL(string: finalUrl!) ?? URL.start

        if !skipHistory {
            while history.count > TabSBrowser.historySize {
                history.remove(at: 0)
            }
            if history.isEmpty || history.last?.url?.absoluteString != finalUrl,
                let cleanUrl = url.clean {

                history.append(HistoryItem(url: cleanUrl, title: title))
                var histories = [NSDictionary]()
                if let arrayOfDict = UserDefaults.standard.value(forKey: kOldHisotries) as? [NSDictionary] {
                    histories = arrayOfDict
                }
                if !histories.contains(where: { (dict) -> Bool in
                    return dict.value(forKey: "path") as? String == cleanUrl.absoluteString && dict.value(forKey: "title") as? String == title
                }) {
                    histories.append(HistoryItem(url: cleanUrl, title: title).getHistoryDictionary())
                    UserDefaults.standard.setValue(histories, forKey: kOldHisotries)
                }
                
            }
        }

        skipHistory = false

        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        
        if let url = webView.url {
            self.url = url
        }

        progress = 0

        let error = error as NSError

        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            return
        }

        // "The operation couldn't be completed. (Cocoa error 3072.)" - useless
        if error.domain == NSCocoaErrorDomain && error.code == NSUserCancelledError {
            return
        }

        // "Frame load interrupted" - not very helpful.
        if error.domain == "WebKitErrorDomain" && error.code == 102 {
            return
        }

        var isTLSError = false
        var msg = error.localizedDescription

        // https://opensource.apple.com/source/libsecurity_ssl/libsecurity_ssl-36800/lib/SecureTransport.h
        if error.domain == NSOSStatusErrorDomain {
            switch (error.code) {
            case Int(errSSLProtocol): /* -9800 */
                msg = NSLocalizedString("TLS protocol error", comment: "")
                isTLSError = true

            case Int(errSSLNegotiation): /* -9801 */
                msg = NSLocalizedString("TLS handshake failed", comment: "")
                isTLSError = true

            case Int(errSSLXCertChainInvalid): /* -9807 */
                msg = NSLocalizedString("TLS certificate chain verification error (self-signed certificate?)", comment: "")
                isTLSError = true

            case -1202:
                isTLSError = true

            default:
                break
            }
        }

        if error.domain == NSURLErrorDomain && error.code == -1202 {
            isTLSError = true
        }

        let u = error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String

        if u != nil {
            msg += "\n\n\(u!)"
        }

        if let ok = error.userInfo[ORIGIN_KEY] as? NSNumber,
            !ok.boolValue {

            print("[Tab \(index)] not showing dialog for non-origin error: \(msg) (\(error))")

            return self.webView(webView, didFinish: navigation)
        }

        print("[Tab \(index)] showing error dialog: \(msg) (\(error)")

        let alert = AlertSBrowser.build(message: msg)

        if (u != nil && isTLSError) {
            alert.addAction(AlertSBrowser.destructiveAction(
                NSLocalizedString("Ignore for this host", comment: ""),
                handler: { _ in
                    // self.url will hold the URL of the UIWebView which is the last *successful* request.
                    // We need the URL of the *failed* request, which should be in `u`.
                    // (From `error`'s `userInfo` dictionary.
                    if let url = URL(string: u!),
                        let host = url.host {

                        let hs = HostSettingsSBrowser.for(host)
                        hs.ignoreTlsErrors = true
                        hs.save().store()

                        // Retry the failed request.
                        self.load(url)
                    }
                }))
        }

        tabDelegate?.presentSBTab(alert, nil)//vishnu

        self.webView(webView, didFinish: navigation)
        
        
        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    
    
    
    // MARK: Private Methods

    /**
    Handles all IPC calls from JavaScript.

    Calls look like this: `endlessipc://<action>[/<param1>][/<param2>][?<value>]`

    - parameter URL: The IPC URL
    - parameter navigationType: The navigation type as given by webView:shouldStartLoadWith:navigationType:
    - returns: false always, which can be used as a return for #webView:shouldStartLoadWith:navigationType:, because IPC calls should never allow any further loading.
    */
    private func handleIpc(_ url: URL, _ navigationType: WKNavigationType) -> Bool {

        let action = url.host
        let param1 = url.pathComponents.count > 1 ? url.pathComponents[1] : nil
        let param2 = url.pathComponents.count > 2 ? url.pathComponents[2] : nil
        let value = url.query?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding

        if action == "console.log" {
            print("[Tab \(index)] [console.\(param1 ?? "log")] \(value ?? "(nil)")")
            // No callback needed.
            return false
        }

        print("[Tab \(index)] [IPC]: action=\(action ?? "(nil)"), param1=\(param1 ?? "(nil)"), param2=\(param2 ?? "(nil)"), value=\(value ?? "(nil)")")

        switch action {
        case "noop":
            ipcCallback("")

            return false

        case "window.open":
            // Only allow windows to be opened from mouse/touch events, like a normal browser's popup blocker.
            if navigationType == .linkActivated //.linkClicked//vishnu
            {
                let child = tabDelegate?.addNewTabSBrowser(nil)
                child?.parentId = hash
                child?.ipcId = param1

                if let param1 = param1?.escapedForJavaScript {
                    ipcCallback("__endless.openedTabs[\"\(param1)\"].opened = true;")
                } else {
                    ipcCallback("")
                }
            } else {
                // TODO: Show a "popup blocked" warning?
                print("[Tab \(index)] blocked non-touch window.open() (nav type \(navigationType))");

                if let param1 = param1?.escapedForJavaScript {
                    ipcCallback("__endless.openedTabs[\"\(param1)\"].opened = false;")
                } else {
                    ipcCallback("")
                }
            }

            return false

        case "window.close":
            let alert = AlertSBrowser.build(
                message: NSLocalizedString("Allow this page to close its tab?", comment: ""),
                title: NSLocalizedString("Confirm", comment: ""),
                actions: [
                    AlertSBrowser.defaultAction(handler: { _ in self.tabDelegate?.removeTabSBrowser(self, focus: nil) }),
                    AlertSBrowser.cancelAction()
            ])

            tabDelegate?.presentSBTab(alert, nil)//vishnu
            

            ipcCallback("")

            return false

        default:
            break
        }

        if action?.hasPrefix("fakeWindow.") ?? false {
            guard let tab = tabDelegate?.getTabSBrowser(ipcId: param1) else {
                if let param1 = param1?.escapedForJavaScript {
                    ipcCallback("delete __endless.openedTabs[\"\(param1)\"];")
                }
                else {
                    ipcCallback("")
                }

                return false
            }

            switch action {
            case "fakeWindow.setName":
                // Setters, just write into target webview.
                if let value = value?.escapedForJavaScript {
                    tab.stringByEvaluatingJavaScript(from: "window.name = \"\(value)\";")
                }

                ipcCallback("")

            case "fakeWindow.setLocation":
                if let value = value?.escapedForJavaScript {
                    tab.stringByEvaluatingJavaScript(from: "window.location = \"\(value)\";")
                }

                ipcCallback("")

            case "fakeWindow.setLocationParam":
                if let param2 = param2, TabSBrowser.validParams.contains(param2),
                    let value = value?.escapedForJavaScript {

                    tab.stringByEvaluatingJavaScript(from: "window.location.\(param2) = \"\(value)\";")
                }
                else {
                    print("[Tab \(index)] window.\(param2 ?? "(nil)") not implemented");
                }

                ipcCallback("")

            case "fakeWindow.close":
                tabDelegate?.removeTabSBrowser(tab, focus: nil)

                ipcCallback("")

            default:
                break
            }
        }

        return false
    }

    private func ipcCallback(_ payload: String) {
        let callback = "(function() { \(payload); __endless.ipcDone = (new Date()).getTime(); })();"

        print("[Tab \(index)] [IPC]: calling back with: %@", callback)

        stringByEvaluatingJavaScript(from: callback)
    }
  
    
    
    
}
