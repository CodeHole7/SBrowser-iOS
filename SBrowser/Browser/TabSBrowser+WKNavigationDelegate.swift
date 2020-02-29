//
//  TabSBrowser+WKNavigationDelegate.swift
//  SBrowser
//
//  Created by Jin Xu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension TabSBrowser: WKNavigationDelegate, WKUIDelegate {
    
    
    /**
    Must match injected.js
    */
    private static let validParams = ["hash", "hostname", "href", "pathname",
                                      "port", "protocol", "search", "username",
                                      "password", "origin"]

    private static let universalLinksWorkaroundKey = "yayprivacy"
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame == nil {

            //let viewController = UIApplication.shared.keyWindow!.rootViewController as! BrowserViewController
            //viewController.newTabFromOverview()
      
            webView.load(navigationAction.request)
            //let tabb = viewController.addNewTabSBrowser(navigationAction.request.url, forRestoration: false, transition: .default)
            
            //return tabb?.webView
        }
        return nil
    }
    
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
     

//    class func supportedMIMETypes() -> Set<AnyHashable>? {
//
//        if supportedMIMETypesSSupportedCredentialTypes == nil {
//            supportedMIMETypesSSupportedCredentialTypes = Set<AnyHashable>(objects: "application/x-pkcs12", "application/x-x509-ca-cert", "application/pkix-cert", nil)
//            assert(supportedMIMETypesSSupportedCredentialTypes != nil)
//        }
//        return supportedMIMETypesSSupportedCredentialTypes
//    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
         print(" delegate 2: ################################ decidePolicyFor navigationResponse: WKNavigationResponse")
        
        
        //ps//
        let supportedMIMETypesSSupportedCredentialTypes = ["application/x-pkcs12", "application/x-x509-ca-cert", "application/pkix-cert"]
        if navigationResponse.response.url!.pathExtension == "sbc"{
            var byte = navigationResponse.response
            print("sbc")
            decisionHandler(.cancel)
            return
        }
       // else
        if let mimeType = navigationResponse.response.mimeType {
            // do some thing with the MIME type
            var fileMIMEType = "" //yeh

            fileMIMEType = mimeType.lowercased() 
            if fileMIMEType == nil {
             //   _stopReceive(withStatus: "No Content-Type!")
            } else if !supportedMIMETypesSSupportedCredentialTypes.contains(fileMIMEType) {
             //   _stopReceive(withStatus: "Unsupported Content-Type (\(fileMIMEType))")
            } else {
                //  _updateStatus("Response OK.")
                
                print("has mime type")
                let av = UIAlertController(title: "", message: "This website is trying to download a configuration profile. Do you want to allow this?", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Ignore", style: .default, handler: { (action) in
                //    decisionHandler(.cancel)
                    
                }))
                av.addAction(UIAlertAction(title: "Allow", style: .cancel, handler: { _ in
                    let cc :CredentialsController = CredentialsController()
  
                    
                    // If we have JavaScript blocked, these will be empty.
                    let finalUrl = navigationResponse.response.url
                    let viewController = UIApplication.shared.keyWindow!.rootViewController as! BrowserViewController
             
                    viewController.ShowBlackLayer()
                    print("log: ###################### Step 1 : Receiving will Start")
                    //mj//We will be sending the response from here and just download the file and use it.
                    cc._startReceive("\(finalUrl!)", obj: viewController, resp:navigationResponse.response as! HTTPURLResponse )
                    
             
                }))
                //self.present(av, animated: true, completion: nil)
//                NotificationCenter.default.addObserver(self, selector: #selector(ShowImportVc), name: Notification.Name("importstart"), object: nil)
                
                self.tabDelegate?.presentSBTab(av, nil)//vishnu
                decisionHandler(.cancel)
                return
            }
            
        } else {
            // response has no MIME type, do some special handling
        }
        //ps//
        
//        guard let response = navigationResponse.response as? HTTPURLResponse,
//          let url = navigationResponse.response.url else {
//          decisionHandler(.cancel)
//          return
//        }
//
//        if let headerFields = response.allHeaderFields as? [String: String] {
//          let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
//          cookies.forEach { cookie in
//            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
//          }
//        }
//        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
//        if let urlResponse = navigationResponse.response as? HTTPURLResponse,
//           let url = urlResponse.url,
//           let allHeaderFields = urlResponse.allHeaderFields as? [String : String] {
//           //let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
//
//           //HTTPCookieStorage.shared.setCookies(cookies , for: url, mainDocumentURL: nil)
//           //decisionHandler(.allow)
//            //setCookies(dictionary: allHeaderFields)
//
//            let dataStore = WKWebsiteDataStore.default()
//dataStore.httpCookieStore.getAllCookies({ (cookies) in
//    print(cookies)
//    HTTPCookieStorage.shared.setCookies(cookies , for: url, mainDocumentURL: nil)
//})
//
//        }
        
        decisionHandler(.allow)
        
    }
    
    func setCookies(dictionary: [String: String]) {
        for (name, value) in dictionary {
            if let cookie = HTTPCookie(properties: [
                .domain: ".xxxx.com",
                .path: "/",
                .name: name,
                .value: value
                ]) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
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
        print(" delegate 1: ################################ decidePolicyFor navigationAction: WKNavigationAction")
        
        guard var url = navigationAction.request.url else {
            return decisionHandler(WKNavigationActionPolicy.cancel, preferences)
        }
        
        if url.scheme?.lowercased() == "endlessipc" {
            return handleIpc(url, navigationAction.navigationType) ? decisionHandler(WKNavigationActionPolicy.allow, preferences) : decisionHandler(WKNavigationActionPolicy.cancel, preferences)
        }
        if url.pathExtension == "sbc"{
            
            let pathurl = pathForTemporaryFile(withPrefix: "localPath")
            
            let downloadurl = URL(fileURLWithPath: "\(pathurl ?? "").\(url.pathExtension)")
            if FileManager.default.fileExists(atPath: downloadurl.path){
                do{
                    try FileManager.default.removeItem(at: downloadurl)
                }catch{
                    
                }
            }
            DispatchQueue.main.async {
                rootviewController.ShowBlackLayer()
            }
            Downloader.load(url: url, to: downloadurl, completion: {
                
                let data = NSData(contentsOf: downloadurl)
                let count = data!.length / MemoryLayout<UInt8>.size
                
                // create an array of Uint8
                var byteArray = [UInt8](repeating: 0, count: count)
                
                // copy bytes into array
                data!.getBytes(&byteArray, length:count)
                
                var passwordarr = [UInt8]()
                for i in byteArray.count-33..<byteArray.count{
                    passwordarr.append(byteArray[i])
                }
                
                let value = Data(bytes: &byteArray, count: byteArray.count-32)
                
                let pfxPath  = "\(pathurl ?? "").pfx"
                do{
                    try value.write(to: URL(fileURLWithPath: pfxPath))
                }catch{
                    
                }
                
                let key = "PHGu98&6iw/ryfhj^^hgy=uiygTYR%00"
                let iv = "cF3$Z1-U89a;]m45K"
                
                let sv = UnsafeRawBufferPointer(start: passwordarr, count: passwordarr.count)
                let keyv = UnsafeRawBufferPointer(start: key, count: key.count)
                let ivv = UnsafeRawBufferPointer(start: iv, count: iv.count)
                
                
                guard let vl = decrypt(sv, key: keyv, iv: ivv)else {
                    return
                }
                let passwordDecrypted = vl.map { UInt8($0) }
                
                if let pstring = String(bytes: passwordDecrypted, encoding: .utf8) {
                    print(pstring)

                    let password = pstring
                    var err: OSStatus
                    var importedItems: CFArray?
                    importedItems = nil
                    let importeddata = NSData(contentsOf: URL(fileURLWithPath: pfxPath))
                    
                    err = SecPKCS12Import((importeddata as! CFData), ([
                        kSecImportExportPassphrase : password
                        ] as CFDictionary?)!, &importedItems)
                    
                    if err == 0{
                        //paswordcorrect
                        if let importedItems = importedItems {
                            for itemDict in importedItems as [AnyObject] {
                                guard let itemDict = itemDict as? [AnyHashable : Any] else {
                                    continue
                                }
                                let identity: SecIdentity = itemDict[kSecImportItemIdentity as String] as! SecIdentity
                                //= SBProfilesInfoVC()
                                
                                DispatchQueue.main.async {
                                    let vc = SBProfilesInfoVC()
                                    
                                    let obj = UINavigationController(rootViewController: vc)
                                    shouldRedirectAfterCertImport = true
                                    vc.identity = identity
                                  //  var redirecturl  = url.deletingLastPathComponent().appendingPathComponent("redirect")
                                    //rootviewController.searchBar.text = redirecturl.path
                                    redirecturl = url.deletingLastPathComponent().appendingPathComponent("redirect")
                                    vc.isViewFromSettings = false
                                    rootviewController.HideBlackLayer()
                                    rootviewController.present(obj, animated: true, completion: nil)
                                }

                                
                                break;
                                
                                
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            rootviewController.HideBlackLayer()
                        }
                        //password incorrect
                        //                                    let alert = UIAlertController(title: "Password Incorrect", message: "", preferredStyle: .alert)
                        //                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //                                        self.ShowCertificatesPasswordAlert(data: data, type: type)
                        //                                        return
                        //                                    }))
                        //                                    self.present(alert, animated: false, completion: nil)
                        //
                       // return
                    }

                    
                } else {
                    print("not a valid UTF-8 sequence")
                    DispatchQueue.main.async {
                        rootviewController.HideBlackLayer()
                    }
                }
                
                
            })
            return decisionHandler(WKNavigationActionPolicy.allow, preferences)
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
    
   /* ///
    func resolvePendingAuthenticationChallenge(with credential: URLCredential?) {
        
        var challenge: URLAuthenticationChallenge?
       
       // We clear out our record of the pending challenge and then pass the real work
       // over to the client thread (which ensures that the challenge is resolved on
       // the same thread we received it on).
        
        completionHandler = pendingChallengeCompletionHandler
        challenge = pendingChallenge
        pendingChallenge = nil
        pendingChallengeCompletionHandler = nil
        pendingDidCancelAuthenticationChallengeHandler = nil

            if credential == nil {
                self.authenticatingHTTPProtocol(self, logWithFormat: "challenge %@ resolved without credential", challenge?.protectionSpace.authenticationMethod)
                completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
            } else {
                self.authenticatingHTTPProtocol(self, logWithFormat: "challenge %@ resolved with <%@ %p>", challenge?.protectionSpace.authenticationMethod, credential.self, credential)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
       
    }*/

    ///
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        var successfulAuth = false
        
        print(" delegate 3: ################################ didReceive challenge: URLAuthenticationChallenge")
        /*if let url = webView.url, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTwisetechlabs.comrust {
            if let trust = challenge.protectionSpace.serverTrust {
                if HostSettingsSBrowser.for(webView.url?.host).ignoreTlsErrors {
                    successfulAuth = true
                    completionHandler(URLSession.AuthChallengeDisposition.useCredential,URLCredential.init(trust: trust))
                } else {
                    JAHPAuthenticatingHTTPProtocol.temporarilyAllow(webView.url, forWebViewTab: sharedBrowserVC?.currentTab, isOCSPRequest: true)
                    
                    let modifyOCSPURL: ((_ url: URL?) -> URL)? = { url in
                        JAHPAuthenticatingHTTPProtocol.temporarilyAllow(webView.url, forWebViewTab: sharedBrowserVC?.currentTab, isOCSPRequest: true)
                        return url!
                    }
                    
                    let authURLSessionDelegate = AppDelegate.shared?.certificateAuthentication.authURLSessionDelegate
                    authURLSessionDelegate?.evaluateTrust(trust, modifyOCSPURLOverride: modifyOCSPURL, sessionOverride: JAHPAuthenticatingHTTPProtocol.sharedDemux.session, completionHandler: completionHandler)
                    
                    
                }
            }
        }*/
        
        /*
        let space = challenge.protectionSpace
        let storage = URLCredentialStorage.shared
        
        let authenticatingHTTPProtocol = JAHPAuthenticatingHTTPProtocol()
        
        // If we have existing credentials for this realm, try them first.
        if challenge.previousFailureCount < 1,
            let credential = storage.credentials(for: space)?.first?.value {

            storage.set(credential, for: space)
            authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)

            completionHandler(.useCredential, nil)
            return
        }
        
        DispatchQueue.main.async {
            let alert = AlertSBrowser.build(
                message: (space.realm?.isEmpty ?? true) ? space.host : "\(space.host): \"\(space.realm!)\"",
                title: NSLocalizedString("Authentication Required", comment: ""))

            AlertSBrowser.addTextField(alert, placeholder:
                NSLocalizedString("Username", comment: ""))

            AlertSBrowser.addPasswordField(alert, placeholder:
                NSLocalizedString("Password", comment: ""))

            alert.addAction(AlertSBrowser.cancelAction { _ in
                challenge.sender?.cancel(challenge)
                authenticatingHTTPProtocol.client?.urlProtocol(
                    authenticatingHTTPProtocol,
                    didFailWithError: NSError(domain: NSCocoaErrorDomain,
                                              code: NSUserCancelledError,
                                              userInfo: [ORIGIN_KEY: true]))
            })

            alert.addAction(AlertSBrowser.defaultAction(NSLocalizedString("Log In", comment: "")) { _ in
                // We only want one set of credentials per protectionSpace.
                // In case we stored incorrect credentials on the previous
                // login attempt, purge stored credentials for the
                // protectionSpace before storing new ones.
                for c in storage.credentials(for: space) ?? [:] {
                    storage.remove(c.value, for: space)
                }

                let textFields = alert.textFields

                let credential = URLCredential(user: textFields?.first?.text ?? "",
                                               password: textFields?.last?.text ?? "",
                                               persistence: .forSession)

                storage.set(credential, for: space)
                authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)
            })

            self.tabDelegate?.presentSBTab(alert, nil)//vishnu
        }
        
        
        
        
        sharedBrowserVC?.currentTab?.sslCertificate = nil
        
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            
            if let certificate = SSLCertificate(secTrustRef: serverTrust) {
                
                sharedBrowserVC?.currentTab?.sslCertificate = certificate
                AppDelegate.shared?.sslCertCache.setObject(certificate, forKey: challenge.protectionSpace.host as NSString)
            }
            
            
        }else{
             completionHandler(.useCredential, nil)
        }
        */
        
        //sharedBrowserVC?.currentTab?.sslCertificate = nil
        guard let hostname = webView.url?.host else {
            return
        }

        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        if authenticationMethod == NSURLAuthenticationMethodDefault || authenticationMethod == NSURLAuthenticationMethodHTTPBasic || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
          
            ///mj//
            let space = challenge.protectionSpace
            let storage = URLCredentialStorage.shared

            // If we have existing credentials for this realm, try them first.
            if challenge.previousFailureCount < 1,
                let credential = storage.credentials(for: space)?.first?.value {

                storage.set(credential, for: space)
                //resolvePendingAuthenticationChallenge(with: credential)
                
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)

               return
            }
            ///mj//
            
            let av = UIAlertController(title: "Authentication Required", message: String(format: "\"\(hostname)\" Password Protected Area", hostname), preferredStyle: .alert)
            av.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "User Name"
            })
            av.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            })

            av.addAction(UIAlertAction(title: "Log In", style: .default, handler: { (action) in
                guard let userId = av.textFields?.first?.text else{
                    return
                }
                guard let password = av.textFields?.last?.text else {
                    return
                }
                 ///mj//
                // We only want one set of credentials per protectionSpace.
                // In case we stored incorrect credentials on the previous
                // login attempt, purge stored credentials for the
                // protectionSpace before storing new ones.
                for c in storage.credentials(for: space) ?? [:] {
                    storage.remove(c.value, for: space)
                }
                ///mj//
                
                
                let credential = URLCredential(user: userId, password: password, persistence: .forSession)
                completionHandler(.useCredential,credential)
                
                ///mj///
                storage.set(credential, for: space)
               // authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)
                ///mj//
                
                return
            }))
            av.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(.cancelAuthenticationChallenge, nil);
                
                self.progress = 0
                NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
                return
            }))
            //self.present(av, animated: true, completion: nil)
            self.tabDelegate?.presentSBTab(av, nil)//vishnu
        }else if authenticationMethod == NSURLAuthenticationMethodServerTrust{
            // needs this handling on iOS 9
            
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                
                if let certificate = SSLCertificate(secTrustRef: serverTrust) {
                    
                    sharedBrowserVC?.currentTab?.sslCertificate = certificate
                    AppDelegate.shared?.sslCertCache.setObject(certificate, forKey: challenge.protectionSpace.host as NSString)
                }
                completionHandler(.useCredential, credential)
            }
            
            else{
                 //completionHandler(.useCredential, nil)
                completionHandler(.performDefaultHandling, nil)
            }
            
            return
            //completionHandler(.performDefaultHandling, nil);
        }
        else if authenticationMethod == NSURLAuthenticationMethodClientCertificate{
        //mj// we need to implement this and check the identies
            var credential: URLCredential?
            // If we got an identity, create a credential for that identity.
            var identities = Credentials.shared().identities! as NSArray
            
            var newidentitiesararray = NSMutableArray()
            for i in 0..<identities.count{
                
                var identity: SecIdentity?
                var identityCertificate: SecCertificate?
                var identitySubject: CFString?
                
                identity = (identities[i] as! SecIdentity)
                _ = SecIdentityCopyCertificate(identity!, &identityCertificate)
                identitySubject = SecCertificateCopySubjectSummary(identityCertificate!)
                //     assert(identitySubject != nil)
                
                
                let expiredate = Credentials.shared()?.getCertificateexpireDate(identityCertificate!) as! NSDate
   
                
                
                let todayDate = Date()
                if todayDate > expiredate as Date{
                    //expire
                }else{
                    newidentitiesararray.add(identity)
                }
                
            }
            
            identities = newidentitiesararray

            if identities.count != 0{
                if identities.count == 1{
                    let identity = identities[0]
                    var persistence: URLCredential.Persistence
                    persistence = DebugOptions.shared().credentialPersistence
                    credential = URLCredential(identity: identity as! SecIdentity, certificates: nil, persistence: persistence)

                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential);
                }else{
                    
                    let listobj = ClientIdentityController(challenge: challenge, identity: identities as! [Any])
                    let rootviewController = UIApplication.shared.keyWindow!.rootViewController as! BrowserViewController
                    rootviewController.identityChoosen = false
                    listobj?.delegate = rootviewController
                    rootviewController.identity = nil
                    
                    
//                    listobj!.modalPresentationStyle = .popover
//                    listobj?.isModalInPopover = true
                    
             //       rootviewController.present(listobj!, self)
                    
                        rootviewController.present(listobj!, animated: true)//, completion: { () in
//
//                        print("")
//                        completionHandler(.cancelAuthenticationChallenge, nil);
//                    })
               
                    DispatchQueue.global().async {
                        while rootviewController.identityChoosen == false{
                            DispatchQueue.main.async {
                                
                            }
                        }
                        if rootviewController.identity != nil{
                            var credential: URLCredential?
                            var persistence: URLCredential.Persistence
                            persistence = DebugOptions.shared().credentialPersistence
                            credential = URLCredential(identity: rootviewController.identity!, certificates: nil, persistence: persistence)
                            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential);
                        }else{
                            completionHandler(.cancelAuthenticationChallenge, nil);
                        }
                        
                        //completionHandler(.cancelAuthenticationChallenge, nil);
                        print("completionHandler")
                    }
                    
                    
                    //challenge.sender?.use(credential, for: challenge)
                
                   // completionHandler(.cancelAuthenticationChallenge, nil);
                    //listobj?.modalPresentationStyle = .
                    
                }
            }else{
                completionHandler(.cancelAuthenticationChallenge, nil);
            }
        }
        else{
            progress = 0
            NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        
        
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

        progress = 0
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
        
        progress = 0
        NotificationCenter.default.post(name: NSNotification.Name(kWebViewFinishOrError), object: nil, userInfo: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progress = 0
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
  
    
//    @objc func ShowImportVc(notification: Notification){
//
//
//        if let mimetype = notification.userInfo!["mimetype"] as? String {
//            if let fileData = notification.userInfo!["fileData"] as? Data {
//                if let url = notification.userInfo!["url"] as? URL {
//                    let vc = CredentialImportController(credentialData: fileData, type: mimetype)
//                    vc!.delegate = self
//                    vc!.origin = url
//                    //  presentModalViewController(vc, animated: true)
//                    self.tabDelegate?.presentSBTab(vc!, nil)//vishnu
//                }
//            }
//        }
//
//    }
    

            
        
}
