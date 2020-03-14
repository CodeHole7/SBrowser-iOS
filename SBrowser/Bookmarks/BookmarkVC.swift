//
//  BookmarkVC.swift
//  SBrowser
//
//  Created by Jin Xu on 23/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka

protocol BookmarkVCDelegate {

    func needsReload()
}



class BookmarkVC: SBFixedFormVC {
    
    var index: Int?
    var delegate: BookmarkVCDelegate?

    private var bookmark: BookmarkSBrowser?

    private var sceneGoneStoreImmediately = false

    private let favIconRow = FavIconRowSBrowser() {
        $0.disabled = true
        $0.placeholderImage = BookmarkSBrowser.defaultIcon
    }
    
    private let titleRow = TextRow() {
        $0.placeholder = NSLocalizedString("Title", comment: "Bookmark title placeholder")
    }

    private let urlRow =  URLRow() {
        $0.placeholder = NSLocalizedString("Address", comment: "Bookmark URL placeholder")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Was called via "+" (add).
        if index == nil {

            // Check, if we have a valid URL in the current tab. If so, prefill with that.
            if let info = AddSiteSBrowserVC.getCurrentTabInfo() {

                // Check, if this page is already bookmarked. If so, edit that.
                if let bookmark = BookmarkSBrowser.all.first(where: { $0.url == info.url }) {
                    self.bookmark = bookmark
                    index = BookmarkSBrowser.all.firstIndex(of: bookmark)
                }
                else {
                    titleRow.value = info.title
                    urlRow.value = info.url

                    acquireIcon()
                }
            }
        }
        else {
            bookmark = BookmarkSBrowser.all[index!]
        }

        navigationItem.title = index == nil
            ? NSLocalizedString("Add Bookmark", comment: "Scene titlebar")
            : NSLocalizedString("Edit Bookmark", comment: "Scene title")

        if index == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .save, target: self, action: #selector(addNew))

            // Don't allow to store empty bookmarks.
            navigationItem.rightBarButtonItem?.isEnabled = urlRow.value != nil
        }

        if let bookmark = bookmark {
            favIconRow.value = bookmark.icon
            titleRow.value = bookmark.name
            urlRow.value = bookmark.url

            if bookmark.icon == nil {
                acquireIcon()
            }
        }

        form
            +++ favIconRow
            <<< titleRow
            <<< urlRow
            .onChange { row in
                self.acquireIcon()
                self.navigationItem.rightBarButtonItem?.isEnabled = row.value != nil
            }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Store changes, if user edits an existing bookmark or bookmark was created
        // with #addNew.
        if index != nil {
            bookmark?.name = titleRow.value

            // Don't allow empty URL.
            if let url = cleanUrl() {
                bookmark?.url = url
            }

            bookmark?.icon = favIconRow.value

            BookmarkSBrowser.store()

            delegate?.needsReload()

            sceneGoneStoreImmediately = true
        }
    }


    // MARK: Private Methods

    @objc private func addNew() {
        if urlRow != nil {
            bookmark = BookmarkSBrowser()

            BookmarkSBrowser.all.append(bookmark!)
            // Trigger store in #viewWillDisappear by setting index != nil.
            index = BookmarkSBrowser.all.firstIndex(of: bookmark!)

            navigationController?.popViewController(animated: true)
        }
    }

    private func acquireIcon() {
        guard let url = cleanUrl() else {
            return
        }

        BookmarkSBrowser.icon(for: url) { image in
            self.favIconRow.value = image
            self.favIconRow.reload()

            // User stored bookmark and left scene.
            // If we return to late, store the icon of the bookmark immediately,
            // so we don't loose that information.
            if self.sceneGoneStoreImmediately {
                self.bookmark?.icon = image
                BookmarkSBrowser.store()
            }
        }
    }

    private func cleanUrl() -> URL? {
        guard let url = urlRow.value else {
            return nil
        }

        var urlc = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if urlc?.scheme?.isEmpty ?? true {
            urlc?.scheme = "https"
        }

        // When no URL formatting is given, a domain is always parsed as a path.
        // Users enter domains here most likely, though.
        if urlc?.host?.isEmpty ?? true {
            let host = urlc?.path
            urlc?.host = host
            urlc?.path = "/"
        }

        return urlc?.url
    }
    
    

}
