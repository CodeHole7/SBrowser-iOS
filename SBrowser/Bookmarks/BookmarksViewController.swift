//
//  BookmarksViewController.swift
//  SBrowser
//
//  Created by JinXu on 23/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, BookmarkVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!

    private lazy var doneBt = UIBarButtonItem(barButtonSystemItem: .done,
                                              target: self, action: #selector(dismiss_))

    private lazy var doneEditingBt = UIBarButtonItem(barButtonSystemItem: .done,
                                                     target: self, action: #selector(edit))
    private lazy var editBt = UIBarButtonItem(barButtonSystemItem: .edit,
                                              target: self, action: #selector(edit))

    private let searchController = UISearchController(searchResultsController: nil)
    private var filtered = [BookmarkSBrowser]()

    private var _needsReload = false

    /**
     true, if a search filter is currently set by the user.
    */
    private var isFiltering: Bool {
        return searchController.isActive
            && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    @objc
    class func instantiate() -> UINavigationController {
        return UINavigationController(rootViewController: self.init())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        toolbarItems = [
            //UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(title: "Add Bookmark", style: .done, target: self, action: #selector(add)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]

        navigationItem.title = NSLocalizedString("Bookmarks", comment: "Scene title")
        updateButtons()

        tableView.register(BookmarkCellSBrowser.nib, forCellReuseIdentifier: BookmarkCellSBrowser.reuseId)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if _needsReload {
            tableView.reloadData()
            _needsReload = false
        }
    }


    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isFiltering ? filtered : BookmarkSBrowser.all).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCellSBrowser.reuseId, for: indexPath) as! BookmarkCellSBrowser

        return cell.set((isFiltering ? filtered : BookmarkSBrowser.all)[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isFiltering
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isFiltering
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            BookmarkSBrowser.all[indexPath.row].icon = nil // Delete icon file.
            BookmarkSBrowser.all.remove(at: indexPath.row)
            BookmarkSBrowser.store()
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        BookmarkSBrowser.all.insert(BookmarkSBrowser.all.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
        BookmarkSBrowser.store()
    }


    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index: Int? = indexPath.row

        if isFiltering {
            index = BookmarkSBrowser.all.firstIndex(of: filtered[index!])
        }

        if let index = index {
            if tableView.isEditing {
                let vc = BookmarkVC()
                vc.delegate = self
                vc.index = index

                navigationController?.pushViewController(vc, animated: true)
            } else {
                let bookmark = BookmarkSBrowser.all[index]

                sharedBrowserVC?.addNewTabSBrowser (
                    bookmark.url, transition: .notAnimated) { _ in
                        self.dismiss_()
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }


    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        if let search = searchController.searchBar.text?.lowercased() {
            filtered = BookmarkSBrowser.all.filter() {
                $0.name?.lowercased().contains(search) ?? false
                    || $0.url?.absoluteString.lowercased().contains(search) ?? false
            }
        }
        else {
            filtered.removeAll()
        }

        tableView.reloadData()
    }

    // MARK: BookmarkViewControllerDelegate

    func needsReload() {
        _needsReload = true
    }

    // MARK: Actions

    @objc private func dismiss_() {
        navigationController?.dismiss(animated: true)
    }

    @objc private func add() {
        let vc = BookmarkVC()
        vc.delegate = self

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func edit() {
        tableView.setEditing(!tableView.isEditing, animated: true)

        updateButtons()
    }


    // MARK: Private Methods

    private func updateButtons() {
        navigationItem.leftBarButtonItem = tableView.isEditing
            ? nil
            : doneBt

        var items = toolbarItems

        items?.append(tableView.isEditing ? doneEditingBt : editBt)

        toolbar.setItems(items, animated: true)
    }
}
