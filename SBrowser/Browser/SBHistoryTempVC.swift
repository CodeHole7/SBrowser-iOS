//
//  SBHistoryTempVC.swift
//  SBrowser
//
//  Created by JinXu on 29/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBHistoryTempVC: UITableViewController {

    

    private var tab: TabSBrowser?
    private var history: [HistoryItem]?

    @objc
    class func instantiate(_ tab: TabSBrowser) -> UINavigationController {
        let vc = SBHistoryTempVC()
        vc.tab = tab

        return UINavigationController(rootViewController: vc)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("History", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(_dismiss))

        history = tab?.history.reversed()
        history?.removeFirst()
    }


    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, tab?.history.count ?? 1) - 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "history")

        let url = history?[indexPath.row].url

        cell.textLabel?.text = history?[indexPath.row].title ?? BrowserViewController.prettyTitle(url)
        cell.detailTextLabel?.text = url?.absoluteString

        return cell
    }


    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = history?[indexPath.row] {
            tab?.load(item.url)
        }

        _dismiss()
    }

    // MARK: Private Methods

    @objc
    private func _dismiss() {
        dismiss(animated: true)
    }

}
