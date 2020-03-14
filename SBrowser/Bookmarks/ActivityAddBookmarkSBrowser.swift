//
//  ActivityAddBookmarkSBrowser.swift
//  SBrowser
//
//  Created by Jin Xu on 23/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class ActivityAddBookmarkSBrowser: UIActivity {

    private var urls: [URL]?

    override var activityType: UIActivity.ActivityType? {
        return ActivityType(String(describing: type(of: self)))
    }

    override var activityTitle: String? {
        return NSLocalizedString("Add Bookmark", comment: "")
    }

    override var activityImage: UIImage? {
        return UIImage(named: "bookmarks")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if !(item is URL) || BookmarkSBrowser.contains(url: item as! URL) {
                return false
            }
        }

        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        urls = activityItems.filter({ $0 is URL }) as? [URL]
    }

    override func perform() {
        DispatchQueue.global(qos: .userInitiated).async {
            let tabs = sharedBrowserVC?.tabs

            for url in self.urls ?? [] {
                var title: String?

                // .title contains a call which needs the UI thread.
                DispatchQueue.main.sync {
                    title = tabs?.first(where: { $0.url == url })?.title
                }

                let b = BookmarkSBrowser(name: title, url: url.absoluteString)
                BookmarkSBrowser.all.append(b)
                BookmarkSBrowser.store() // First store, so the user sees it immediately.

                var done = false
                b.acquireIcon {
                    done = true
                }

                while !done {
                    Thread.sleep(forTimeInterval: 0.2)
                }

                // Second store, so the user sees the icon, too.
                BookmarkSBrowser.store()
            }

            DispatchQueue.main.async {
                self.activityDidFinish(true)
            }
        }
    }
}
