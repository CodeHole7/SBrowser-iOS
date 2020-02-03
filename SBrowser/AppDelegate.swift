//
//  AppDelegate.swift
//  SBrowser
//
//  Created by JinXu on 20/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JAHPAuthenticatingHTTPProtocolDelegate {
    
    @objc
    static let socksProxyPort = 39050

    @objc
    static let httpProxyPort = 0

    @objc
    class var shared: AppDelegate? {
        var delegate: UIApplicationDelegate?

        if Thread.isMainThread {
            delegate = UIApplication.shared.delegate
        } else {
            DispatchQueue.main.sync {
                delegate = UIApplication.shared.delegate
            }
        }

        return delegate as? AppDelegate
    }
    
    @objc
    let sslCertCache = NSCache<NSString, SSLCertificate>()

    @objc
    let certificateAuthentication = CertificateAuthentication()

    @objc
    let hstsCache = HSTSCache.retrieve()

    @objc
    let cookieJar = CookieJar()
    
    var testing: Bool {
        return NSClassFromString("XCTestProbe") != nil
            || ProcessInfo.processInfo.environment["ARE_UI_TESTING"] != nil
    }
    
    var window: UIWindow?
       
    
    override var keyCommands: [UIKeyCommand]? {
        // If settings are up or something else, ignore shortcuts.
        if !(window?.rootViewController is BrowserViewController)
            || sharedBrowserVC?.presentedViewController != nil {
            return nil
        }

        var commands = [
            UIKeyCommand(input: "[", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Go Back", comment: "")),
            UIKeyCommand(input: "]", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Go Forward", comment: "")),
            UIKeyCommand(input: "b", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Show Bookmarks", comment: "")),
            UIKeyCommand(input: "l", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Focus URL Field", comment: "")),
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Reload TabSBrowser", comment: "")),
            UIKeyCommand(input: "t", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Create New TabSBrowser", comment: "")),
            UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(handle(_:)),
                         discoverabilityTitle: NSLocalizedString("Close Tab", comment: "")),
        ]

        for i in 1 ... 10 {
            commands.append(UIKeyCommand(
                input: String(i % 10), modifierFlags: .command, action: #selector(handle(_:)),
                discoverabilityTitle: String(format: NSLocalizedString("Switch to TabSBrowser %d", comment: ""), i)))
        }

        if UIResponder.currentFirstResponder() is UIWebView {
            commands.append(contentsOf: allKeyBindings)
        }

        return commands
    }
    
    
    let defaultUserAgent: String? = {
        var uaparts = WKWebView(frame: .zero)
            .stringByEvaluatingJavaScript(from: "navigator.userAgent")
            .components(separatedBy: " ")

        // Assume Safari major version will match iOS major.
        let osv = UIDevice.current.systemVersion.components(separatedBy: ".")
        let index = (uaparts.endIndex ) - 1
        uaparts.insert("Version/\(osv.first ?? "0").0", at: index)

        // Now tack on "Safari/XXX.X.X" from WebKit version.
        for p in uaparts {
            if p.contains("AppleWebKit/") {
                uaparts.append(p.replacingOccurrences(of: "AppleWebKit", with: "Safari"))
                break
            }
        }

        return uaparts.joined(separator: " ")
    }()
    
    


    private let allKeyBindings: [UIKeyCommand] = {
        let modPermutations: [UIKeyModifierFlags] = [
            .alphaShift,
            .shift,
            .control,
            .alternate,
            .command,
            [.command, .alternate],
            [.command, .control],
            [.control, .alternate],
            [.control, .command],
            [.control, .alternate, .command],
            []
        ]

        var chars = "`1234567890-=\tqwertyuiop[]\\asdfghjkl;'\rzxcvbnm,./ "
        chars.append(UIKeyCommand.inputEscape)
        chars.append(UIKeyCommand.inputUpArrow)
        chars.append(UIKeyCommand.inputDownArrow)
        chars.append(UIKeyCommand.inputLeftArrow)
        chars.append(UIKeyCommand.inputRightArrow)

        var bindings = [UIKeyCommand]()

        for mod in modPermutations {
            for char in chars {
                bindings.append(UIKeyCommand(input: String(char), modifierFlags: mod, action: #selector(handle(_:))))
            }
        }

        return bindings
    }()

    private var alert: UIAlertController?
    
    
    
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        //UserDefaults.standard.removeObject(forKey: kOldHisotries)
        
        BookmarkSBrowser.firstRunSetup()
        
        SBTabSecurity.restore()
        JAHPAuthenticatingHTTPProtocol.setDelegate(self)
        JAHPAuthenticatingHTTPProtocol.start()
        migrate()
        adjustMuteSwitchBehavior()
        DownloadHelper.deleteDownloadsDirectory()

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        if let shortcut = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handle(shortcut)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(kAddNewBlankTab), object: nil, userInfo: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        application.ignoreSnapshotOnNextApplicationLaunch()
        sharedBrowserVC?.becomesInvisible()

        SBBlurredSnapshot.create()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if !testing {
            HostSettingsSBrowser.store()
            hstsCache?.persist()
        }

        SBTabSecurity.handleBackgrounding()
        application.ignoreSnapshotOnNextApplicationLaunch()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SBBlurredSnapshot.remove()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        cookieJar.clearAllNonWhitelistedData()
        DownloadHelper.deleteDownloadsDirectory()
        application.ignoreSnapshotOnNextApplicationLaunch()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        dismissModalsAndCall {
            sharedBrowserVC?.addNewTabSBrowser(url.withFixedScheme)
        }
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        handle(shortcutItem) {
            completionHandler(true)
        }
    }

    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {

        if extensionPointIdentifier == .keyboard {
            return SettingsSBrowser.thirdPartyKeyboards
        }

        return true
    }

    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return self.application(application, shouldRestoreApplicationState: coder)
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {

        if testing {
            return false
        }

        if SettingsSBrowser.stateRestoreLock {
            print("[\(String(describing: type(of: self)))] Previous startup failed, not restoring application state.")

            SettingsSBrowser.stateRestoreLock = false

            return false
        }

        SettingsSBrowser.stateRestoreLock = true

        return true
    }

    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {

        return !testing && !SBTabSecurity.isClearOnBackground
    }


    // MARK: JAHPAuthenticatingHTTPProtocolDelegate

    func authenticatingHTTPProtocol(_ authenticatingHTTPProtocol: JAHPAuthenticatingHTTPProtocol?,
                                    logMessage message: String) {
        print("[JAHPAuthenticatingHTTPProtocol] \(message)")
    }

    func authenticatingHTTPProtocol(_ authenticatingHTTPProtocol: JAHPAuthenticatingHTTPProtocol,
                                    canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace)
        -> Bool {

        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest
            || protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic
    }

    func authenticatingHTTPProtocol(_ authenticatingHTTPProtocol: JAHPAuthenticatingHTTPProtocol,
                                    didReceive challenge: URLAuthenticationChallenge)
        -> JAHPDidCancelAuthenticationChallengeHandler? {

        let space = challenge.protectionSpace
        let storage = URLCredentialStorage.shared

        // If we have existing credentials for this realm, try them first.
        if challenge.previousFailureCount < 1,
            let credential = storage.credentials(for: space)?.first?.value {

            storage.set(credential, for: space)
            authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)

            return nil
        }

        DispatchQueue.main.async {
            self.alert = AlertSBrowser.build(
                message: (space.realm?.isEmpty ?? true) ? space.host : "\(space.host): \"\(space.realm!)\"",
                title: NSLocalizedString("Authentication Required", comment: ""))

            AlertSBrowser.addTextField(self.alert!, placeholder:
                NSLocalizedString("Username", comment: ""))

            AlertSBrowser.addPasswordField(self.alert!, placeholder:
                NSLocalizedString("Password", comment: ""))

            self.alert?.addAction(AlertSBrowser.cancelAction { _ in
                challenge.sender?.cancel(challenge)
                authenticatingHTTPProtocol.client?.urlProtocol(
                    authenticatingHTTPProtocol,
                    didFailWithError: NSError(domain: NSCocoaErrorDomain,
                                              code: NSUserCancelledError,
                                              userInfo: [ORIGIN_KEY: true]))
            })

            self.alert?.addAction(AlertSBrowser.defaultAction(NSLocalizedString("Log In", comment: "")) { _ in
                // We only want one set of credentials per protectionSpace.
                // In case we stored incorrect credentials on the previous
                // login attempt, purge stored credentials for the
                // protectionSpace before storing new ones.
                for c in storage.credentials(for: space) ?? [:] {
                    storage.remove(c.value, for: space)
                }

                let textFields = self.alert?.textFields

                let credential = URLCredential(user: textFields?.first?.text ?? "",
                                               password: textFields?.last?.text ?? "",
                                               persistence: .forSession)

                storage.set(credential, for: space)
                authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)
            })

            sharedBrowserVC?.present(self.alert!)
        }

        return nil
    }

    func authenticatingHTTPProtocol(_ authenticatingHTTPProtocol: JAHPAuthenticatingHTTPProtocol,
                                    didCancel challenge: URLAuthenticationChallenge) {

        if (alert?.isViewLoaded ?? false) && alert?.view.window != nil {
            alert?.dismiss(animated: false)
        }
    }

    // MARK: Public Methods

    /**
    Setting `AVAudioSessionCategoryAmbient` will prevent audio from `UIWebView` from pausing
    already-playing audio from other apps.
    */
    func adjustMuteSwitchBehavior() {
        let session = AVAudioSession.sharedInstance()

        if SettingsSBrowser.muteWithSwitch {
            try? session.setCategory(.ambient)
            try? session.setActive(false)
        }
        else {
            try? session.setCategory(.playback)
        }
    }

    func show(_ viewController: UIViewController?, _ completion: ((Bool) -> Void)? = nil) {
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.backgroundColor = .accent
        }

        window?.rootViewController?.restorationIdentifier = String(describing: type(of: viewController))
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve,
                          animations: {}, completion: completion)
    }


    // MARK: Private Methods

    /**
    Handle per-version upgrades or migrations.
    */
    private func migrate() {
        let lastBuild = UserDefaults.standard.integer(forKey: "last_build")

        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal

        let thisBuild = fmt.number(
            from: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "")?.intValue ?? 0

        if lastBuild < thisBuild {
            print("[\(String(describing: type(of: self)))] migrating from build \(lastBuild) -> \(thisBuild)")

            SBMigration.migrate()

            UserDefaults.standard.set(thisBuild, forKey: "last_build")
        }
    }

    private func handle(_ shortcut: UIApplicationShortcutItem, completion: (() -> Void)? = nil) {
        if shortcut.type.contains("OpenNewTab") {
            dismissModalsAndCall {
                sharedBrowserVC?.addEmptyTabAndFocus()
                completion?()
            }
        }
        else if shortcut.type.contains("ClearData") {
            dismissModalsAndCall {
                sharedBrowserVC?.removeAllTabs()
                completion?()
            }
        }
        else {
            print("[\(String(describing: type(of: self)))] Unable to handle shortcut type '\(shortcut.type)'!")
            completion?()
        }
    }

    /**
    In case, a modal view controller is overlaying the `BrowsingViewController`, we close it
    *before* adding a new tab.

    - parameter completion: Callback when dismiss is done or immediately when no dismiss was necessary.
    */
    private func dismissModalsAndCall(completion: @escaping () -> Void) {
        if sharedBrowserVC?.presentedViewController != nil {
            sharedBrowserVC?.dismiss(animated: true, completion: completion)
        }
        // If there's no modal view controller, however, the completion block
        // would never be called.
        else {
            completion()
        }
    }

    @objc
    private func handle(_ keyCommand: UIKeyCommand) {
        if keyCommand.modifierFlags == .command {
            switch keyCommand.input {
            case "b":
                sharedBrowserVC?.showBookmarks()
                return

            case "l":
                sharedBrowserVC?.focusSearchField()
                return

            case "r":
                sharedBrowserVC?.currentTab?.refresh()
                return

            case "t":
                sharedBrowserVC?.addEmptyTabAndFocus()
                return

            case "w":
                sharedBrowserVC?.removeCurrentTab()
                return

            case "[":
                sharedBrowserVC?.currentTab?.goBack()
                return

            case "]":
                sharedBrowserVC?.currentTab?.goForward()
                return

            default:
                for i in 0 ... 9 {
                    if keyCommand.input == String(i), let browsingUi = sharedBrowserVC {
                        browsingUi.switchToTab(i == 0 ? browsingUi.tabs.count - 1 : i - 1)
                        return
                    }
                }
            }
        }

        sharedBrowserVC?.currentTab?.handleKeyCommand(keyCommand)
    }
    
    
    
    
    
    
    

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SBrowser")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

