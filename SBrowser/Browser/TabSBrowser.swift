//
//  TabSBrowser.swift
//  SBrowser
//
//  Created by JinXu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import WebKit
import QuickLook

protocol TabSBrowserDelegate: class {
    func updateChrome(_ sender: TabSBrowser?)

    func addNewTabSBrowser(_ url: URL?) -> TabSBrowser?

    func addNewTabSBrowser(_ url: URL?, forRestoration: Bool,
                   transition: BrowserViewController.Transition,
                   completion: ((Bool) -> Void)?) -> TabSBrowser?

    func removeTabSBrowser(_ tab: TabSBrowser, focus: TabSBrowser?)

    func getTabSBrowser(ipcId: String?) -> TabSBrowser?

    func getTabSBrowser(hash: Int?) -> TabSBrowser?

    func getIndex(of tab: TabSBrowser) -> Int?

    //func present(_ vc: UIViewController, _ sender: UIView?)

    func unfocusSearchField()
}

class TabSBrowser: UIView {

    @objc
    enum SecureMode: Int {
        case insecure
        case mixed
        case secure
        case secureEv
    }


    weak var tabDelegate: TabSBrowserDelegate?

    var title: String {
        if let downloadedFile = downloadedFile {
            return downloadedFile.lastPathComponent
        }

        if let title = stringByEvaluatingJavaScript(from: "document.title") {
            if !title.isEmpty {
                return title
            }
        }

        return BrowserViewController.prettyTitle(url)
    }

    var parentId: Int?

    var ipcId: String?

    @objc
    var url = URL.start

    @objc
    var index: Int {
        return tabDelegate?.getIndex(of: self) ?? -1
    }

    private(set) var needsRefresh = false

    @objc(applicableHTTPSEverywhereRules)
    var applicableHttpsEverywhereRules = NSMutableDictionary()

    @objc(applicableURLBlockerTargets)
    var applicableUrlBlockerTargets = NSMutableDictionary()

    @objc(SSLCertificate)
    var sslCertificate: SSLCertificate? {
        didSet {
            if sslCertificate == nil {
                secureMode = .insecure
            }
            else if sslCertificate?.isEV ?? false {
                secureMode = .secureEv
            }
            else {
                secureMode = .secure
            }
        }
    }

    @objc
    var secureMode = SecureMode.insecure

    @nonobjc
    var progress: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.tabDelegate?.updateChrome(self)
            }
        }
    }

    static let historySize = 40
    var skipHistory = false

//    var history = [HistoryViewController.Item]()
//
    override var isUserInteractionEnabled: Bool {
        didSet {
            if previewController != nil {
                if isUserInteractionEnabled {
                    overlay.removeFromSuperview()
                }
                else {
                    overlay.add(to: self)
                }
            }
        }
    }

    private(set) lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        
//        view.scalesPageToFit = true
//        view.allowsInlineMediaPlayback = true

        return view.add(to: self)
    }()

    var scrollView: UIScrollView {
        return webView.scrollView
    }

    var canGoBack: Bool {
        return  parentId != nil || webView.canGoBack
    }

    var canGoForward: Bool {
        return webView.canGoForward
    }

    var isLoading: Bool {
        return webView.isLoading
    }

    var previewController: QLPreviewController?

    /**
    Add another overlay (a hack to create a transparant clickable view)
    to disable interaction with the file preview when used in the tab overview.
    */
    private(set) lazy var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.11
        view.isUserInteractionEnabled = false

        return view
    }()

    var downloadedFile: URL?

    private(set) lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()

        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh Page")

        return refresher
    }()


    init(restorationId: String?) {
        super.init(frame: .zero)

        setup(restorationId)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }


    // MARK: Public Methods

    @objc
    func refresh() {
        if url == URL.start {
            BookmarkSBrowser.updateStartPage()
        }

        needsRefresh = false
        skipHistory = true
        webView.reload()
    }

    func stop() {
        webView.stopLoading()
    }

    @objc
    func load(_ url: URL?) {
        var request: URLRequest?

        if let url = url?.withFixedScheme?.real {
            request = URLRequest(url: url)
        }

        load(request)
    }

    func load(_ request: URLRequest?) {
        DispatchQueue.main.async {
            self.webView.stopLoading()
        }

        reset()

        let request = request ?? URLRequest(url: URL.start)

        if let url = request.url {
            if url == URL.start {
                BookmarkSBrowser.updateStartPage()
            }

            self.url = url
        }

        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }

    @objc
    func search(for query: String?) {
        return load(LiveSearchSBrowserViewController.constructRequest(query))
    }

    func reset(_ url: URL? = nil) {
        applicableHttpsEverywhereRules.removeAllObjects()
        applicableUrlBlockerTargets.removeAllObjects()
        sslCertificate = nil
        self.url = url ?? URL.start
    }

    @objc
    func goBack() {
        if webView.canGoBack {
            skipHistory = true
            webView.goBack()
        }
        else if let parentId = parentId {
            tabDelegate?.removeTabSBrowser(self, focus: tabDelegate?.getTabSBrowser(hash: parentId))
        }
    }

    @objc
    func goForward() {
        if webView.canGoForward {
            skipHistory = true
            webView.goForward()
        }
    }

    @discardableResult
    func stringByEvaluatingJavaScript(from script: String) -> String? {
        return webView.stringByEvaluatingJavaScript(from: script)
    }


    // MARK: Private Methods
    
    private var observation: NSKeyValueObservation? = nil

    private func setup(_ restorationId: String? = nil) {
        // Re-register user agent with our hash, which should only affect this UIWebView.
        UserDefaults.standard.register(defaults: ["UserAgent": "\(AppDelegate.shared?.defaultUserAgent ?? "")/\(hash)"])

        if restorationId != nil {
            restorationIdentifier = restorationId
            needsRefresh = true
        }

       // NotificationCenter.default.addObserver(self, selector: #selector(self.progressEstimateChanged(_:)), name: NSNotification.Name("WebProgressEstimateChangedNotification"), object: webView.value(forKeyPath: "documentView.webView"))
        
        observation = webView.observe(\.estimatedProgress, options: [.new]) { _, _ in
            self.progress = Float(self.webView.estimatedProgress)
        }

        // Immediately refresh the page if its host settings were changed, so
        // users sees the impact of their changes.
        NotificationCenter.default.addObserver(forName: .hostSettingsChanged, object: nil, queue: .main)
        { notification in
            let host = notification.object as? String

            // Refresh on default changes and specific changes for this host.
            if host == nil || host == self.url.host {
                self.refresh()
            }
        }

        // This doubles as a way to force the webview to initialize itself,
        // otherwise the UA doesn't seem to set right before refreshing a previous
        // restoration state.
        let hashInUa = stringByEvaluatingJavaScript(from: "navigator.userAgent")?.split(separator: "/").last

        if hashInUa?.compare(String(hash)) != ComparisonResult.orderedSame {
            print("[TabSBrowser \(index)] Aborting, not equal! hashInUa=\(String(describing: hashInUa)), hash=\(hash)")
            abort()
        }

        setupGestureRecognizers()
    }

    @objc
    private func progressEstimateChanged(_ notification: Notification) {
        progress = Float(notification.userInfo?["WebProgressEstimatedProgressKey"] as? Float ?? 0)
    }


    deinit {
        cancelDownload()
        
        observation = nil

        let block = {
           // self.webView.delegate = nil
            self.webView.stopLoading()

            for gr in self.webView.gestureRecognizers ?? [] {
                self.webView.removeGestureRecognizer(gr)
            }

            self.removeFromSuperview()
        }

        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.sync(execute: block)
        }
    }
}
