//
//  TabSBrowser+Helper.swift
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation
import QuickLook
import MobileCoreServices

//#MARK: TabSBrowser + Keyboard
/**
Encapsulates all keyboard handling of a `TabSBrowser`.
*/

extension TabSBrowser {

    /**
    A Keyboard Map Entry.
    */
    private struct Kme {
        let keycode: Int
        let keypressKeycode: Int
        let shiftKeycode: Int

        init(_ keycode: Int, _ keypressKeycode: Int, _ shiftKeycode: Int) {
            self.keycode = keycode
            self.keypressKeycode = keypressKeycode
            self.shiftKeycode = shiftKeycode
        }

        init(_ keycode: Int, _ keypressKeycode: Character, _ shiftKeycode: Character) {
            self.init(keycode, Int(keypressKeycode.asciiValue ?? 0), Int(shiftKeycode.asciiValue ?? 0))
        }

        init(_ keycode: Character, _ keypressKeycode: Character, _ shiftKeycode: Character) {
            self.init(Int(keycode.asciiValue ?? 0), keypressKeycode, shiftKeycode)
        }
    }

    private static let keyboardMap: [String: Kme] = [
        UIKeyCommand.inputEscape: Kme(27, 0, 0),

        "`": Kme(192, "`", "~"),
        "1": Kme("1", "1", "!"),
        "2": Kme("2", "2", "@"),
        "3": Kme("3", "3", "#"),
        "4": Kme("4", "4", "$"),
        "5": Kme("5", "5", "%"),
        "6": Kme("6", "6", "^"),
        "7": Kme("7", "7", "&"),
        "8": Kme("8", "8", "*"),
        "9": Kme("9", "9", "("),
        "0": Kme("0", "0", ")"),
        "-": Kme(189, "-", "_"),
        "=": Kme(187, "=", "+"),
        "\u{8}": Kme(8, 0, 0),

        "\t": Kme(9, 0, 0),
        "q": Kme("Q", "q", "Q"),
        "w": Kme("W", "w", "W"),
        "e": Kme("E", "e", "E"),
        "r": Kme("R", "r", "R"),
        "t": Kme("T", "t", "T"),
        "y": Kme("Y", "y", "Y"),
        "u": Kme("U", "u", "U"),
        "i": Kme("I", "i", "I"),
        "o": Kme("O", "o", "O"),
        "p": Kme("P", "p", "P"),
        "[": Kme(219, "[", "{"),
        "]": Kme(221, "]", "}"),
        "\\": Kme(220, "\\", "|"),

        "a": Kme("A", "a", "A"),
        "s": Kme("S", "s", "S"),
        "d": Kme("D", "d", "D"),
        "f": Kme("F", "f", "F"),
        "g": Kme("G", "g", "G"),
        "h": Kme("H", "h", "H"),
        "j": Kme("J", "j", "J"),
        "k": Kme("K", "k", "K"),
        "l": Kme("L", "l", "L"),
        ";": Kme(186, ";", ":"),
        "'": Kme(222, "'", "\""),
        "\r": Kme(13, 0, 0),

        "z": Kme("Z", "z", "Z"),
        "x": Kme("X", "x", "X"),
        "c": Kme("C", "c", "C"),
        "v": Kme("V", "v", "V"),
        "b": Kme("B", "b", "B"),
        "n": Kme("N", "n", "N"),
        "m": Kme("M", "m", "M"),
        ",": Kme(188, ",", "<"),
        ".": Kme(190, ".", ">"),
        "/": Kme(191, "/", "/"),

        " ": Kme(" ", " ", " "),
        UIKeyCommand.inputLeftArrow: Kme(37, 0, 0),
        UIKeyCommand.inputUpArrow: Kme(38, 0, 0),
        UIKeyCommand.inputRightArrow: Kme(39, 0, 0),
        UIKeyCommand.inputDownArrow: Kme(40, 0, 0)
    ]

    @objc
    func handleKeyCommand(_ command: UIKeyCommand) {
        let shiftKey = command.modifierFlags.contains(.shift)
        let ctrlKey = command.modifierFlags.contains(.control)
        let altKey = command.modifierFlags.contains(.alternate)
        let cmdKey = command.modifierFlags.contains(.command)

        var keycode = 0
        var keypressKeycode = 0
        let keyAction: String?

        if let input = command.input,
            let entry = TabSBrowser.keyboardMap[input] {

            keycode = entry.keycode
            keypressKeycode = shiftKey ? entry.shiftKeycode : entry.keypressKeycode
        }

        if keycode < 1 {
            return print("[TabSBrowser \(index)] unknown hardware keyboard input: \"\(command.input ?? "")\"")
        }

        switch command.input {
        case " ":
            keyAction = "__endless.smoothScroll(0, window.innerHeight * 0.75, 0, 0);"

        case UIKeyCommand.inputLeftArrow:
            keyAction = "__endless.smoothScroll(-75, 0, 0, 0);"

        case UIKeyCommand.inputRightArrow:
            keyAction = "__endless.smoothScroll(75, 0, 0, 0);"

        case UIKeyCommand.inputUpArrow:
            keyAction = cmdKey
                ? "__endless.smoothScroll(0, 0, 1, 0);"
                : "__endless.smoothScroll(0, -75, 0, 0);"

        case UIKeyCommand.inputDownArrow:
            keyAction = cmdKey
                ? "__endless.smoothScroll(0, 0, 0, 1);"
                : "__endless.smoothScroll(0, 75, 0, 0);"

        default:
            keyAction = nil
        }

        let js = String(format: "__endless.injectKey(%d, %d, %@, %@, %@, %@, %@);",
                        keycode,
                        keypressKeycode,
                        (ctrlKey ? "true" : "false"),
                        (altKey ? "true" : "false"),
                        (shiftKey ? "true" : "false"),
                        (cmdKey ? "true" : "false"),
                        (keyAction != nil ? "function() { \(keyAction!) }" : "null"))

        print("[TabSBrowser \(index)] hardware keyboard input: \"\(command.input ?? "")\", keycode=\(keycode), keypressKeycode=\(keypressKeycode), modifierFlags=\(command.modifierFlags): shiftKey=\(shiftKey), ctrlKey=\(ctrlKey), altKey=\(altKey), cmdKey=\(cmdKey)")
        print("[TabSBrowser \(index)] injected JS: \(js)")

        stringByEvaluatingJavaScript(from: js)
    }
}




//Mark:- TabsBrowser + DownloadTaskDelegate

extension TabSBrowser: DownloadTaskDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource {

    /**
    Should be called whenever navigation occurs or
    when the WebViewTab is being closed.
    */
    func cancelDownload() {
        if downloadedFile != nil {
            // Delete the temporary file.
            try? FileManager.default.removeItem(atPath: downloadedFile!.path)

            downloadedFile = nil
        }

        if previewController != nil {
            previewController?.view.removeFromSuperview()
            previewController?.removeFromParent()
            previewController = nil
        }

        overlay.removeFromSuperview()
    }


    // MARK: DownloadTaskDelegate

    func didStartDownloadingFile() {
        // Nothing to do here.
    }

    func didFinishDownloading(to location: URL?) {
        DispatchQueue.main.async {
            if location != nil {
                self.downloadedFile = location;
                self.showDownload()
            }
        }
    }

    func setProgress(_ pr: NSNumber?) {
        progress = pr?.floatValue ?? 0
    }


    // MARK: QLPreviewControllerDelegate

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return downloadedFile! as NSURL
    }


    // MARK: QLPreviewControllerDataSource

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return downloadedFile != nil ? 1 : 0
    }

    // MARK: Private Methods

    private func showDownload() {
        previewController = QLPreviewController()
        previewController?.delegate = self
        previewController?.dataSource = self

        sharedBrowserVC?.addChild(previewController!)

        previewController?.view.add(to: self)

        previewController?.didMove(toParent: sharedBrowserVC)

        // Positively show toolbar, as users can't scroll it back up.
        scrollView.delegate?.scrollViewDidScrollToTop?(scrollView)
    }
}

//#Mark:- TabSBrowser + UIGestureRecognizerDelegate

extension TabSBrowser: UIGestureRecognizerDelegate {

    func setupGestureRecognizers() {
        let isRtl = UIView.userInterfaceLayoutDirection(for: webView.semanticContentAttribute) == .rightToLeft

        // Swipe to go back one page.
        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        swipeBack.direction = isRtl ? .left : .right
        swipeBack.delegate = self
        webView.addGestureRecognizer(swipeBack)

        // Swipe to go forward one page.
        let swipeForward = UISwipeGestureRecognizer(target: self, action: #selector(goForward))
        swipeForward.direction = isRtl ? .right : .left
        swipeForward.delegate = self
        webView.addGestureRecognizer(swipeForward)

        // Long press to show context menu.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu(_:)))
        longPress.delegate = self
        webView.addGestureRecognizer(longPress)

        // Hard long press to immediately open link or image in a new tab.
        let forceTouch = VForceTouchGestureRecognizer(target: self, action: #selector(openInNewTab(_:)))
        forceTouch.percentMinimalRequest = 0.4
        forceTouch.delegate = self
        webView.addGestureRecognizer(forceTouch)

        // Pull down to refresh.
        refresher.addTarget(self, action: #selector(refresherTriggered), for: .valueChanged)
        scrollView.addSubview(refresher)
    }


    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if !(gestureRecognizer is UILongPressGestureRecognizer) {
            return false
        }

        if gestureRecognizer.state != .began {
            return true
        }

        let (href, img, _) = analyzeTappedElements(gestureRecognizer)

        if href != nil || img != nil {
            // This is enough to cancel the touch when the long press gesture fires,
            // so that the link being held down doesn't activate as a click once
            // the finger is let up.
            if otherGestureRecognizer is UILongPressGestureRecognizer {
                otherGestureRecognizer.isEnabled = false
                otherGestureRecognizer.isEnabled = true
            }

            return true
        }

        return false
    }


    // MARK: Private Methods

    @objc
    private func showContextMenu(_ gr: UIGestureRecognizer) {
        // Otherwise this will be uselessly called multiple times.
        guard gr.state == .began else {
            return
        }

        let (href, img, message) = analyzeTappedElements(gr)

        if href == nil && img == nil {
            gr.isEnabled = false // Cancels the gesture recognizer.
            gr.isEnabled = true

            return
        }

        let menu = UIAlertController(title: message.isEmpty ? nil : message,
                                     message: (href ?? img)?.absoluteString,
                                     preferredStyle: .actionSheet)

        if href != nil || img != nil {
            let url = href ?? img

            menu.addAction(UIAlertAction(
                title: NSLocalizedString("Open", comment: ""),
                style: .default,
                handler: { _ in
                    self.load(url)
            }))

            menu.addAction(UIAlertAction(
                title: NSLocalizedString("Open in a New Tab", comment: ""),
                style: .default,
                handler: { _ in
                    let child = self.tabDelegate?.addNewTabSBrowser(url)
                    child?.parentId = self.hash
            }))

            menu.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Background Tab", comment: ""),
                style: .default,
                handler: { _ in
                    let child = self.tabDelegate?.addNewTabSBrowser(
                        url, forRestoration: false, transition: .inBackground, completion: nil)
                    child?.parentId = self.hash
            }))

            menu.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Safari", comment: ""),
                style: .default,
                handler: { _ in
                    if let url = url {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
            }))
        }

        if img != nil {
            menu.addAction(UIAlertAction(
                title: NSLocalizedString("Save Image", comment: ""),
                style: .default,
                handler: { _ in
                    JAHPAuthenticatingHTTPProtocol.temporarilyAllow(img, forWebViewTab: self)

                    let task = URLSession.shared.dataTask(with: img!) { data, response, error in
                        if let data = data,
                            let image = UIImage(data: data) {

                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        } else {
                            DispatchQueue.main.async {
                                let alert = AlertSBrowser.build(
                                    message: String(format:
                                        NSLocalizedString("An error occurred downloading image %@", comment: ""),
                                                    img!.absoluteString))

                                self.tabDelegate?.presentSBTab(alert, nil)//vishnu
                            }
                        }
                    }

                    task.resume()
            }))
        }

        menu.addAction(UIAlertAction(
            title: NSLocalizedString("Copy URL", comment: ""), style: .default,
            handler: { _ in
                UIPasteboard.general.string = (href ?? img)?.absoluteString
        }))

        menu.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                     style: .cancel, handler: nil))

        let point = gr.location(in: gr.view)

        menu.popoverPresentationController?.sourceView = gr.view
        menu.popoverPresentationController?.sourceRect = CGRect(
            x: point.x + 35, // Offset for width of the finger.
            y: point.y, width: 1, height: 1)

        tabDelegate?.presentSBTab(menu, nil)//vishnu
    }

    @objc
    private func openInNewTab(_ gr: VForceTouchGestureRecognizer) {
        // Otherwise this will be uselessly called multiple times.
        guard gr.state == .began else {
            return
        }

        // Taptic feedback.
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.success)

        let (href, img, _) = analyzeTappedElements(gr)

        if let url = href ?? img {
            let child = tabDelegate?.addNewTabSBrowser(url)
            child?.parentId = hash
        }
    }

    @objc
    private func refresherTriggered() {
        refresh()

        // Delay just so it confirms to the user that something happened.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refresher.endRefreshing()
        }
    }

    private func analyzeTappedElements(_ gr: UIGestureRecognizer) -> (href: URL?, img: URL?, title: String) {
        var tap = gr.location(in: webView)
        tap.y -= scrollView.contentInset.top

        var elements = NSArray()

        // Translate tap coordinates from view to scale of page.
        if let innerWidth = stringByEvaluatingJavaScript(from: "window.innerWidth"),
            let width = Int(innerWidth),
            let innerHeight = stringByEvaluatingJavaScript(from: "window.innerHeight"),
            let height = Int(innerHeight) {

            let windowSize = CGSize(width: width, height: height)

            let viewSize = webView.frame.size
            let ratioX = windowSize.width / viewSize.width
            let ratioY = windowSize.height / viewSize.height
            let tapOnPage = CGPoint(x: tap.x * ratioX, y: tap.y * ratioY)

            // Now find, if there are usable elements at those coordinates and extract their attributes.
            if let json = stringByEvaluatingJavaScript(from: "JSON.stringify(__endless.elementsAtPoint(\(tapOnPage.x), \(tapOnPage.y)));"),
                let data = json.data(using: .utf8),
                let array = try? JSONSerialization.jsonObject(with: data, options: []) as? NSArray {

                elements = array
            }
        }

        var href = ""
        var img = ""
        var title = ""

        for element in elements {
            guard let element = element as? NSDictionary,
                let k = element.allKeys.first as? String,
                let attrs = element.object(forKey: k) as? NSDictionary
            else {
                continue
            }

            if k == "a" {
                href = attrs.object(forKey: "href") as? String ?? ""

                // Only use if image title is blank.
                if title.isEmpty {
                    title = attrs.object(forKey: "title") as? String ?? ""
                }
            }
            else if k == "img" {
                img = attrs.object(forKey: "src") as? String ?? ""

                title = attrs.object(forKey: "title") as? String ?? ""

                if title.isEmpty {
                    title = attrs.object(forKey: "alt") as? String ?? ""
                }
            }
        }

        return (href: href.isEmpty ? nil : URL(string: href),
                img: img.isEmpty ? nil : URL(string: img),
                title: title)
    }
}

//#Mark: - TabSBrowser + UIActivityItemSource

extension TabSBrowser: UIActivityItemSource {

    private var uti: String? {
        return try? downloadedFile?.resourceValues(forKeys: [URLResourceKey.typeIdentifierKey]).typeIdentifier
    }

    private var isImageOrAv: Bool {
        if let uti = uti as CFString? {
            return UTTypeConformsTo(uti, kUTTypeImage)
                || UTTypeConformsTo(uti, kUTTypeAudiovisualContent)
        }

        return false
    }

    private var isDocument: Bool {
        if let uti = uti as CFString? {
            return UTTypeConformsTo(uti, kUTTypeData)
                && !UTTypeConformsTo(uti, kUTTypeHTML)
                && !UTTypeConformsTo(uti, kUTTypeXML)
        }

        return false
    }



    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let file = downloadedFile,
            isImageOrAv || isDocument {
            return file
        }

        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {

        print("[\(String(describing: type(of: self)))] activityType=\(String(describing: activityType))")

        if let downloadedFile = downloadedFile,
            let activityType = activityType,
            (activityType == .print
                || activityType == .markupAsPDF
                || activityType == .mail
                || activityType == .openInIBooks
                || activityType == .airDrop
                || activityType == .copyToPasteboard
                || activityType == .saveToCameraRoll
                || activityType.rawValue == "com.apple.CloudDocsUI.AddToiCloudDrive") {

            // Return local file URL -> The file will be loaded and shared from there
            // and it will use the correct file name.
            return downloadedFile
        }

        if activityType == .message && isImageOrAv {
            return downloadedFile
        }

        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {

        return uti ?? kUTTypeURL as String
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                thumbnailImageForActivityType activityType: UIActivity.ActivityType?,
                                suggestedSize size: CGSize) -> UIImage? {

        UIGraphicsBeginImageContext(size)

        if let context = UIGraphicsGetCurrentContext() {
            if downloadedFile != nil {
                previewController?.view.layer.render(in: context)
            }
            else {
                webView.layer.render(in: context)
            }
        }

        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return thumbnail
    }
}
