//
//  BrowserViewController.swift
//  SBrowser
//
//  Created by Jin Xu on 20/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

internal var sharedBrowserVC: BrowserViewController?



class BrowserViewController: UIViewController, TabSBrowserDelegate, CredentialImportControllerDelegate, ClientIdentityControllerDelegate {
  

//var challenge: URLAuthenticationChallenge?
    var identity: SecIdentity?
    var identityChoosen = true
    func identityView(_ controller: ClientIdentityController!, didChoose identity: SecIdentity!) {
        identityChoosen = true
        
        self.identity = identity
        dismiss(animated: true)
        return
        
//        var credential: URLCredential?
//        var persistence: URLCredential.Persistence
//        persistence = DebugOptions.shared().credentialPersistence
//        credential = URLCredential(identity: identity!, certificates: nil, persistence: persistence)
       // challenge?.sender?.use(credential!, for: challenge!)
        
    }
    func _clientIdentityResolvedWithIdentity(identity: SecIdentity!){//todo hatao
        print("called")
    }
    
    
    
func credentialImport(_ credentialImport: CredentialImportController!, didImportWith status: CredentialImportStatus) {
    
    //dismissModalViewController(animated: true)
    dismiss(animated: true)
    
    switch status {
        case kCredentialImportStatusCancelled:
            print("Import cancelled")
        case kCredentialImportStatusFailed:
           // var alert: UIAlertView?

         //   _updateStatus("Import failed")

//            alert = UIAlertView(title: "Import Failed", message: "", delegate: nil, cancelButtonTitle: "Dismiss", otherButtonTitles: "")
//            assert(alert != nil)
//
//            alert?.show()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Import Failed", message: "Unsupported Content Type!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
            //self.present(alert, self.view)
        }
        
        
        case kCredentialImportStatusSucceeded:
            //updateStatus("Import succeeded")
            Credentials.shared().refresh()
        default:
            break
    }

}
    
    
    @objc
    class var defaultBrowserVC: BrowserViewController? {
        return sharedBrowserVC
    }
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet {
            searchBar.textField.leftView = encryptionBt
            searchBar.textField.rightView = reloadBt
        }
    }
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var viewFooterHeightConstraint: NSLayoutConstraint? { // Not available on iPad
        didSet {
            toolbarHeight = viewFooterHeightConstraint?.constant
        }
    }
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var viewTabsCollection: UIView!
    @IBOutlet weak var collectionViewTabs: UICollectionView! {
        didSet {
            collectionViewTabs.dragInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var mainTools: UIStackView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnTabs: UIButton!{
        didSet {
            btnTabs.setTitleColor(btnTabs.tintColor, for: .normal)
            //btnTabs.addTarget(self, action: #selector(showOverview), for: .touchUpInside)
        }
    }
    @IBOutlet weak var btnSettings: UIButton!
    
    @IBOutlet weak var tabsTools: UIView!
    @IBOutlet weak var btnPrivateAddTab: UIButton!
    @IBOutlet weak var btnAddTab: UIButton!
    @IBOutlet weak var btnDoneTab: UIButton!
    
    @IBOutlet weak var btnSecurity: UIButton!
    
    
    @objc
    enum Transition: Int {
        case `default`
        case notAnimated
        case inBackground
    }
    
    @objc
    var tabs = [TabSBrowser]()
    
    private var currentTabIndex = -1
    
    private static let reloadImg = UIImage(named: "reload")
    private static let stopImg = UIImage(named: "close")
    
    var searchBarHeight: CGFloat!
    var toolbarHeight: CGFloat? // Not available on iPad
    lazy var liveSearchVc = LiveSearchSBrowserViewController()

    @objc
    var currentTab: TabSBrowser? {
        get {
            return currentTabIndex < 0 || currentTabIndex >= tabs.count ? tabs.last : tabs[currentTabIndex]
        }
        set {
            if let tab = newValue {
                currentTabIndex = tabs.firstIndex(of: tab) ?? -1
            }
            else {
                currentTabIndex = -1
            }

            if currentTab?.needsRefresh ?? false {
                currentTab?.refresh()
            }
        }
    }
        
    
    lazy var encryptionBt: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        button.addTarget(self, action: #selector(action), for: .touchUpInside)

        return button
    }()

    private lazy var reloadBt: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.setImage(BrowserViewController.reloadImg, for: .normal)

        if #available(iOS 13, *) {
            button.tintColor = .label
        }
        else {
            button.tintColor = .black
        }

        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true

        button.addTarget(self, action: #selector(action), for: .touchUpInside)

        return button
    }()
    
    
    
    
    var blackLayer = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sharedBrowserVC = self
        updateUIOnTabSelection(isEnable: false)
        
        collectionViewTabs.register(TabCellSBrowser.nib, forCellWithReuseIdentifier: TabCellSBrowser.reuseIdentifier)
        collectionViewTabs.delegate = self
        collectionViewTabs.dataSource = self
        collectionViewTabs.dragDelegate = self
        collectionViewTabs.dropDelegate = self
        
                
        for tab in tabs {
            tab.add(to: container)
        }
        
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        updateChrome()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.webViewFinishOrErrorNotificaiton(notification:)), name: NSNotification.Name(kWebViewFinishOrError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addNewBlankTab(notification:)), name: NSNotification.Name(kAddNewBlankTab), object: nil)
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let nc = NotificationCenter.default

        nc.addObserver(self,
                       selector: #selector(keyboardWillShow(notification:)),
                       name: UIResponder.keyboardWillShowNotification,
                       object: nil)

        nc.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)),
                       name: UIResponder.keyboardWillHideNotification,
                       object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // We made it this far, remove lock on previous startup.
        SettingsSBrowser.stateRestoreLock = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let nc = NotificationCenter.default

        nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        var tabInfo = [[String: Any]]()

        for tab in tabs {
            tabInfo.append(["url": tab.url])

            // TODO: From old code. Why here this side effect?
            // Looks strange.
            tab.restorationIdentifier = tab.url.absoluteString
        }

        coder.encode(tabInfo, forKey: "webViewTabs")
        coder.encode(NSNumber(value: currentTabIndex), forKey: "curTabIndex")
    }

    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)

        let tabInfo = coder.decodeObject(forKey: "webViewTabs") as? [[String: Any]]

        for info in tabInfo ?? [] {
            debug("Try restoring tab with \(info).")

            if let url = info["url"] as? URL {
                addNewTabSBrowser(url, forRestoration: true, transition: .notAnimated)
            }
        }

        if let index = coder.decodeObject(forKey: "curTabIndex") as? NSNumber {
            currentTabIndex = index.intValue
        }

        for tab in tabs {
            tab.isHidden = tab != currentTab
            tab.isUserInteractionEnabled = true
            tab.add(to: container)
        }

        currentTab?.refresh()

        updateChrome()
    }
    
    @objc func addNewBlankTab(notification: Notification) {
        addNewTabSBrowser(URL.start, transition: .notAnimated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func clickedBack(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedForward(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedMenu(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedBookmark(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedTabs(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedSettings(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedPrivateTab(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedAddTab(_ sender: UIButton) {
        action(sender)
    }
    
    @IBAction func clickedDone(_ sender: UIButton) {
        hideOverview()
    }
    
    @IBAction func clickedSecurity(_ sender: UIButton) {
        action(sender)
    }
    
    func updateUIOnTabSelection(isEnable: Bool) {
        if isEnable {
            tabsTools.isHidden = false
            mainTools.isHidden = true
            self.viewHeader.isHidden = true
            viewContainer.isHidden = true
            viewTabsCollection.isHidden = false
        } else {
            tabsTools.isHidden = true
            mainTools.isHidden = false
            self.viewHeader.isHidden = false
            viewContainer.isHidden = false
            viewTabsCollection.isHidden = true
        }
    }
    
    @IBAction func action(_ sender: UIButton) {
        unfocusSearchField()

        switch sender {
        case btnSecurity:
            let vc = SBSecurityPopUpViewController()
            vc.host = currentTab?.url.clean?.host ?? currentTab?.url.clean?.path

            present(vc, sender)
            break
        case encryptionBt:
            guard let certificate = currentTab?.sslCertificate,
                let vc = SSLCertificateViewController(sslCertificate: certificate) else {

                    return
            }

            vc.title = currentTab?.url.host
            present(UINavigationController(rootViewController: vc), sender)
            break
        case reloadBt:
            if currentTab?.isLoading ?? false {
                currentTab?.stop()
            } else {
                currentTab?.refresh()
            }
            updateReloadBt()

        case btnBack:
            currentTab?.goBack()

        case btnForward:
            currentTab?.goForward()

        case btnBookmark:
            showBookmarks()
            break
        case btnMenu:
            guard let currentTab = currentTab else {
                return
            }

            present(UIActivityViewController(activityItems: [currentTab], applicationActivities: [ActivityAddBookmarkSBrowser(), TUSafariActivity()]), sender)

        case btnTabs:
            showOverview()
        case btnSettings:
            let vc = SBSettingsVC.instantiate()
           // vc.modalPresentationStyle = .overFullScreen
           // vc.modalTransitionStyle = .crossDissolve
            present(vc)
            break
        case btnAddTab:
            newTabFromOverview()
        default:
            break
        }
    }
    
    func showBookmarks() {
        unfocusSearchField()
        present(BookmarksViewController.instantiate(), btnBookmark)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let kbSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            liveSearchVc.tableView.contentInset = insets
            liveSearchVc.tableView.scrollIndicatorInsets = insets
        }
    }

    @objc func keyboardWillBeHidden(notification: Notification) {
        liveSearchVc.tableView.contentInset = .zero
        liveSearchVc.tableView.scrollIndicatorInsets = .zero
    }

    // MARK: TabDelegate

    func updateChrome(_ sender: TabSBrowser? = nil) {
        debug("#updateChrome progress=\(currentTab?.progress ?? 1)")
        
        if let progress = progressView {
            progress.progress = currentTab?.progress ?? 1
            
            if progress.progress >= 1 {
                if !progress.isHidden {
                    view.transition({ progress.isHidden = true })
                }
            } else {
                if progress.isHidden {
                    view.transition({ progress.isHidden = false })
                }
            }
        }

        updateReloadBt()
        updateSearchField()

        // The last non-hidden should be the one which is showing.
        guard let tab = tabs.last(where: { !$0.isHidden }) else {
            btnSecurity.setTitle(nil, for: UIControl.State.normal)
            btnBack.isEnabled = false
            btnForward.isEnabled = false
            btnMenu.isEnabled = false
            updateTabCount()
            return
        }

        let host = tab.url.host
        let hostBrowser = HostSettingsSBrowser.for(host)
        let preset = SecurityPreset(hostBrowser)

        if preset == .custom {
            btnSecurity.setBackgroundImage(SBSecurityLevelCell.customShieldImage, for: .normal)
            btnSecurity.setTitle(nil, for: .normal)
        } else {
            btnSecurity.setBackgroundImage(SBSecurityLevelCell.shieldImage, for: .normal)
            btnSecurity.setTitle(preset.shortcode, for: .normal)
        }
        
        
        
//        if (!_isOCSPRequest &&
//            [_wvt secureMode] > SecureModeInsecure &&
//            ![[[[_actualRequest URL] scheme] lowercaseString] isEqualToString:@"https"]) {
//            /* an element on the page was not sent over https but the initial request was, downgrade to mixed */
//            if ([_wvt secureMode] > SecureModeInsecure) {
//                [_wvt setSecureMode:SecureModeMixed];
//            }
//        }
        
      //mj//  if tab.url.scheme?.lowercased() == "https" {
       //mj//     tab.secureMode = TabSBrowser.SecureMode.mixed
       //mj// }
        
        

        updateEncryptionBt(tab.secureMode)
        
        btnBack.isEnabled = tab.canGoBack
        btnForward.isEnabled = tab.canGoForward
        btnMenu.isEnabled = !tab.url.isSpecial
        updateTabCount()
    }
    
    @objc    
    func presentSBTab(_ vc: UIViewController, _ sender: UIView?) {
        present(vc, sender)
    }

    @objc
    @discardableResult
    func addNewTabSBrowser(_ url: URL? = nil) -> TabSBrowser? {
        return addNewTabSBrowser(url, forRestoration: false)
    }

    @discardableResult
    func addNewTabSBrowser(_ url: URL? = nil, forRestoration: Bool = false,
                   transition: Transition = .default, completion: ((Bool) -> Void)? = nil) -> TabSBrowser? {

        debug("#addNewTabSBrowser url=\(String(describing: url)), forRestoration=\(forRestoration), transition=\(transition), completion=\(String(describing: completion))")

        let tab = TabSBrowser(restorationId: forRestoration ? url?.absoluteString : nil)

        if !forRestoration {
            tab.load(url)
        }

        tab.tabDelegate = self

        tabs.append(tab)

        tab.scrollView.delegate = self
        tab.isHidden = true
        tab.add(to: container)

        let animations = {
            for otherTab in self.tabs {
                otherTab.isHidden = otherTab != tab
            }
        }

        let completionForeground = { (finished: Bool) in
            self.currentTab = tab

            self.updateChrome()

            completion?(finished)
        }

        switch transition {
        case .notAnimated:
            animations()
            completionForeground(true)

        case .inBackground:
            completion?(true)

        default:
            container.transition(animations, completionForeground)
        }

        return tab
    }

    func removeTabSBrowser(_ tab: TabSBrowser, focus: TabSBrowser? = nil) {
        debug("#removeTab tab=\(tab) focus=\(String(describing: focus))")

        unfocusSearchField()
        container.transition({
            tab.isHidden = true
            (focus ?? self.tabs.last)?.isHidden = false
        }) { _ in
            self.currentTab = focus ?? self.tabs.last
            let hash = tab.hash
            tab.removeFromSuperview()
            self.tabs.removeAll { $0 == tab }
            AppDelegate.shared?.cookieJar.clearNonWhitelistedData(forTab: UInt(hash))
            self.updateChrome()
        }
    }

    func getTabSBrowser(ipcId: String?) -> TabSBrowser? {
        return tabs.first { $0.ipcId == ipcId }
    }

    func getTabSBrowser(hash: Int?) -> TabSBrowser? {
        return tabs.first { $0.hash == hash }
    }

    func getIndex(of tab: TabSBrowser) -> Int? {
        return tabs.firstIndex(of: tab)
    }

    func unfocusSearchField() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    


    // MARK: Public Methods

    @objc
    func becomesVisible() {
        if tabs.count < 1 {
            addNewTabSBrowser()
        }
    }

    @objc
    func becomesInvisible() {
        unfocusSearchField()
    }

    @objc
    func addEmptyTabAndFocus() {
        addNewTabSBrowser() { _ in
            self.focusSearchField()
        }
    }

    @objc
    func switchToTab(_ index: Int) {
        if index < 0 || index >= tabs.count {
            return
        }

        let focussing = tabs[index]

        container.transition({
            for tab in self.tabs {
                tab.isHidden = tab != focussing
            }
        }) { _ in
            self.currentTab = focussing
            self.updateChrome()
        }
    }

    @objc
    func removeCurrentTab() {
        guard let currentTab = currentTab else {
            return
        }

        removeTabSBrowser(currentTab)
    }

    @objc
    func removeAllTabs() {
        for tab in tabs {
            tab.removeFromSuperview()
        }

        tabs.removeAll()

        currentTab = nil

        AppDelegate.shared?.cookieJar.clearAllNonWhitelistedData()

        self.updateChrome()
    }

    @objc
    func focusSearchField() {
        if !searchBar.isFirstResponder {
            searchBar.becomeFirstResponder()
        }
    }

    func debug(_ msg: String) {
        print("[\(String(describing: type(of: self)))] \(msg)")
    }


    // MARK: Private Methods

    /**
    Update and center tab count in `tabsBt`.

    Honors right-to-left languages.
    */
    private func updateTabCount() {
        btnTabs.setTitle("\(tabs.count)", for: .normal)

        var offset: CGFloat = 0

        if let titleLabel = btnTabs.titleLabel, let imageView = btnTabs.imageView {
            if UIView.userInterfaceLayoutDirection(for: btnTabs.semanticContentAttribute) == .rightToLeft {
                offset = imageView.intrinsicContentSize.width / 2 // Move right edge to center of image.
                    + titleLabel.intrinsicContentSize.width / 2 // Move center of text to center of image.
                    + 3 // Correct for double-frame icon.
            }
            else {
                offset = -imageView.intrinsicContentSize.width / 2 // Move left edge to center of image.
                    - titleLabel.intrinsicContentSize.width / 2 // Move center of text to center of image.
                    - 3 // Correct for double-frame icon.
            }
        }

        // 2+2 in vertical direction is correction for double-frame icon
        btnTabs.titleEdgeInsets = UIEdgeInsets(top: 2, left: offset, bottom: -2, right: -offset)
    }
    
    
    /*
    Shows either a reload or stop icon, depending on if the current tab is currently loading or not.
    */
    private func updateReloadBt() {
        if currentTab?.isLoading ?? false {
            reloadBt.setImage(BrowserViewController.stopImg, for: .normal)
            reloadBt.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            print("reload: isLoading")
        } else {
            reloadBt.setImage(BrowserViewController.reloadImg, for: .normal)
            reloadBt.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            print("reload: is not Loading")
        }
    }
    
    @objc func webViewFinishOrErrorNotificaiton(notification: Notification) {
        updateReloadBt()
    }
    
    @objc func ShowBlackLayer(){
        blackLayer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blackLayer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.85)
        let label = UILabel(frame: CGRect(origin: CGPoint(x: (UIScreen.main.bounds.size.width/2)-75, y: UIScreen.main.bounds.size.height/2), size: CGSize(width: 150, height: 25)))
      //  label.font = UIFont(name: label.font.fontName, size: 20)
        label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        label.text = "Receiving"
        let customFont = UIFont(name: "System", size: 30)
        label.font = customFont
        //fromLabel.numberOfLines = 1
        label.baselineAdjustment = .alignBaselines // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        label.textAlignment = .center
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: (UIScreen.main.bounds.size.width/2)-50, y: (UIScreen.main.bounds.size.height/2)+50, width: 100, height: 100) )
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        loadingIndicator.startAnimating();
        blackLayer.addSubview(loadingIndicator)
        blackLayer.addSubview(label)
        self.view.addSubview(blackLayer)
       // print("log: ###################### Step 1 : Receiving Start")
    }
    @objc func HideBlackLayer(){
      //  print("log: ###################### Step 1 : Receiving End")
        DispatchQueue.main.async {
            self.blackLayer.removeFromSuperview()
        }
    }
    @objc func ShowFailedAlert(){
//        DispatchQueue.main.async {
//            let av = UIAlertController(title: "Get Failed", message: "", preferredStyle: .alert)
//            av.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//
//                return
//            }))
//          //  av.modalPresentationStyle = .popover//.fullScreen//.popover
//            self.present(av, self.view)
//        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Get Failed", message: "Unsupported Content Type!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
            //self.present(alert, self.view)
        }
    }

} //End of class
