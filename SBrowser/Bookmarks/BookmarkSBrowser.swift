//
//  BookmarkSBrowser.swift
//  SBrowser
//
//  Created by JinXu on 23/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import FavIcon

@objc
@objcMembers
class BookmarkSBrowser: NSObject {
    
    static let defaultIcon = UIImage(named: "default-icon")!

    private static let keyBookmarks = "bookmarks"
    private static let keyVersion = "version"
    private static let keyName = "name"
    private static let keyUrl = "url"
    private static let keyIcon = "icon"

    private static let version = 2

    private static var root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    private static var bookmarkFilePath = root?.appendingPathComponent("bookmarks.plist")

    private static let defaultBookmarks: [BookmarkSBrowser] = {
        var defaults = [BookmarkSBrowser]()

        defaults.append(BookmarkSBrowser(name: "Wise Tech Labs", url: "http://wisetechlabs.com/"))
        defaults.append(BookmarkSBrowser(name: "New York Times", url: "https://www.nytimes.com"))
        defaults.append(BookmarkSBrowser(name: "BBC", url: "https://www.bbc.com"))
        defaults.append(BookmarkSBrowser(name: "Facebook", url: "https://facebook.com"))
        defaults.append(BookmarkSBrowser(name: "Instagram", url: "https://www.instagram.com"))
        defaults.append(BookmarkSBrowser(name: "Google", url: "https://www.google.com/"))
        defaults.append(BookmarkSBrowser(name: "Twitter", url: "https://twitter.com/"))
        
        return defaults
    }();

    private static var firstUpdateAfterStartDone = false

    static var all: [BookmarkSBrowser] = {

        // Init FavIcon config here, because all code having to do with bookmarks should come along here anyway.
        FavIcon.downloadSession = URLSession.shared
        FavIcon.authorize = { url in
            JAHPAuthenticatingHTTPProtocol.temporarilyAllow(url)

            return true
        }

        var bookmarks = [BookmarkSBrowser]()

        if let path = bookmarkFilePath {
            let data = NSDictionary(contentsOf: path)

            for b in data?[keyBookmarks] as? [NSDictionary] ?? [] {
                bookmarks.append(BookmarkSBrowser(b))
            }
        }

        return bookmarks
    }()

    class func firstRunSetup() {
        if SettingsSBrowser.bookmarkFirstRunDone {
            return
        }

        // Only set up default list of bookmarks, when there's no others.
        if all.count < 1 {
            all.append(contentsOf: defaultBookmarks)

            store()

            DispatchQueue.global(qos: .background).async {
                for bookmark in all {
                    bookmark.acquireIcon() {
                        store()
                    }
                }
                
                SettingsSBrowser.bookmarkFirstRunDone = true
                
                for tab in sharedBrowserVC?.tabs ?? [] {
                    if tab.url == URL.start {
                        if Thread.isMainThread {
                            tab.refresh()
                        }
                        else {
                            DispatchQueue.main.sync(execute: tab.refresh)
                        }
                        
                    }
                }
                
            }
        }
    }

    class func updateStartPage() {
        guard let source = Bundle.main.url(forResource: "newTab", withExtension: "html") else {
            return
        }

        // Always update after start. Language could have been changed.
        if firstUpdateAfterStartDone {
            let fm = FileManager.default

            // If files exist and destination is newer than source, don't do anything. (Upgrades!)
            if let dm = try? fm.attributesOfItem(atPath: URL.start.path)[.modificationDate] as? Date,
                let sm = try? fm.attributesOfItem(atPath: source.path)[.modificationDate] as? Date {

                if dm > sm {
                    return
                }
            }
        }

        guard var template = try? String(contentsOf: source) else {
            return
        }

        // Render bookmarks.
        for i in 0 ... 5 {
            let url: URL
            let name: String
            let icon: UIImage

            if all.count > i,
                let tempUrl = all[i].url {

                url = tempUrl

                name = all[i].name ?? url.host!
                icon = all[i].icon ?? BookmarkSBrowser.defaultIcon
            }
            else {
                // Make sure that the first 6 default bookmarks are available!
                url = defaultBookmarks[i].url!
                name = defaultBookmarks[i].name ?? url.host!
                icon = defaultBookmarks[i].icon ?? BookmarkSBrowser.defaultIcon
            }

            template = template
                .replacingOccurrences(of: "{{ bookmark_url_\(i) }}", with: url.absoluteString)
                .replacingOccurrences(of: "{{ bookmark_name_\(i) }}", with: name)
                .replacingOccurrences(of: "{{ bookmark_icon_\(i) }}",
                    with: "data:image/png;base64,\(icon.pngData()?.base64EncodedString() ?? "")")
        }

        template = template
            .replacingOccurrences(of: "{{ SBrowser }}",
                                  with: Bundle.main.displayName)
            .replacingOccurrences(of: "{{ Learn more about SBrowser }}",
                                  with: String(format: "Learn more about %@", Bundle.main.displayName))

        try? template.write(to: URL.start, atomically: true, encoding: .utf8)

        firstUpdateAfterStartDone = true
    }

    class func add(name: String?, url: String) {
        all.append(BookmarkSBrowser(name: name, url: url))
    }

    @discardableResult
    class func store() -> Bool {
        if let path = bookmarkFilePath {

            // Trigger update of start page when things changed.
            try? FileManager.default.removeItem(at: URL.start)

            for tab in sharedBrowserVC?.tabs ?? [] {
                if tab.url == URL.start {
                    if Thread.isMainThread {
                        tab.refresh()
                    }
                    else {
                        DispatchQueue.main.sync(execute: tab.refresh)
                    }
                    
                }
            }

            let bookmarks = NSMutableArray()

            for b in all {
                bookmarks.add(b.asDic())
            }

            let data = NSMutableDictionary()
            data[keyBookmarks] = bookmarks
            data[keyVersion] = version

            return data.write(to: path, atomically: true)
        }

        return false
    }

    @objc(containsUrl:)
    class func contains(url: URL) -> Bool {
        return all.contains { $0.url == url }
    }

    var name: String?
    var url: URL?

    private var iconName = ""

    private var _icon: UIImage?
    var icon: UIImage? {
        get {
            if _icon == nil && !iconName.isEmpty,
                let path = BookmarkSBrowser.root?.appendingPathComponent(iconName).path {

                _icon = UIImage(contentsOfFile: path)
            }

            return _icon
        }
        set {
            _icon = newValue

            // Remove old icon, if it gets deleted.
            if _icon == nil {
                if !iconName.isEmpty,
                    let path = BookmarkSBrowser.root?.appendingPathComponent(iconName) {

                    try? FileManager.default.removeItem(at: path)
                }

                iconName = ""
            }

            if _icon != nil {
                if iconName.isEmpty {
                    iconName = UUID().uuidString
                }

                if let path = BookmarkSBrowser.root?.appendingPathComponent(iconName) {
                    try? _icon?.pngData()?.write(to: path)
                }
            }
        }
    }

    init(name: String? = nil, url: String? = nil, icon: UIImage? = nil) {
        super.init()

        self.name = name

        if let url = url {
            self.url = URL(string: url)
        }

        self.icon = icon
    }

    init(name: String?, url: String?, iconName: String) {
        super.init()

        self.name = name

        if let url = url {
            self.url = URL(string: url)
        }

        self.iconName = iconName
    }

    convenience init(_ dic: NSDictionary) {
        self.init(name: dic[BookmarkSBrowser.keyName] as? String,
                  url: dic[BookmarkSBrowser.keyUrl] as? String,
                  iconName: dic[BookmarkSBrowser.keyIcon] as? String ?? "")
    }


    // MARK: Public Methods

    class func icon(for url: URL, _ completion: @escaping (_ image: UIImage?) -> Void) {
        try! FavIcon.downloadPreferred(url, width: 128, height: 128) { result in
            if case let .success(image) = result {
                completion(image)
            }
            else {
                completion(nil)
            }
        }

    }

    func acquireIcon(_ completion: @escaping () -> Void) {
        if let url = url {
            BookmarkSBrowser.icon(for: url) { image in
                self.icon = image

                completion()
            }
        }
    }


    // MARK: Private Methods

    private func asDic() -> NSDictionary {
        return NSDictionary(dictionary: [
            BookmarkSBrowser.keyName: name ?? "",
            BookmarkSBrowser.keyUrl: url?.absoluteString ?? "",
            BookmarkSBrowser.keyIcon: iconName,
        ])
    }

}
