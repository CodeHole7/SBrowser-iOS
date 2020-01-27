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
        decisionHandler(WKNavigationActionPolicy.allow, preferences)
    }
    
    
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    
    
    
    
  
    
    
    
}
