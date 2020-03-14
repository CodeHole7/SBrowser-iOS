//
//  SBSearchTableVC.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBSearchTableVC: UITableViewController, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)

    /**
     true, if a search filter is currently set by the user.
    */
    var isFiltering: Bool {
        return searchController.isActive
            && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    var searchText: String? {
        return searchController.searchBar.text?.lowercased()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        assertionFailure("Override in child class!")
    }
}
