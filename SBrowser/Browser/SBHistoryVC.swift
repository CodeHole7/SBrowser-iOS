//
//  SBHistoryVC.swift
//  SBrowser
//
//  Created by Jin Xu on 29/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBHistoryVC: UITableViewController {

    private var history = [HistoryItem]()
    var sbSettingVC: SBSettingsVC?

    @objc
    class func instantiate() -> UINavigationController {
        let vc = SBHistoryVC()
        if let arrayOfDict = UserDefaults.standard.value(forKey: kOldHisotries) as? [NSDictionary] {
            for dict in arrayOfDict {
                vc.history.append(HistoryItem(dictionary: dict))
            }
        }
        return UINavigationController(rootViewController: vc)
    }
    
    private lazy var doneBt = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(_dismiss))
    
    private lazy var deleteAllBt = UIBarButtonItem(title: "Remove All", style: .done, target: self, action: #selector(_removeAll))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("History", comment: "")
        navigationItem.leftBarButtonItem = doneBt
        navigationItem.rightBarButtonItem = deleteAllBt
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if history.count > 0 {
            deleteAllBt.isEnabled = true
            self.tableView.reloadData()
        } else {
            deleteAllBt.isEnabled = false
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "history")

        let url = history[indexPath.row].url

        cell.textLabel?.text = history[indexPath.row].title ?? BrowserViewController.prettyTitle(url)
        cell.detailTextLabel?.text = url?.absoluteString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Are you sure to delete the selected history?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))

            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
                let item = self.history[indexPath.row]
                self.history = self.history.filter({ (h) -> Bool in
                    return h != item
                })
                
                var histories = [NSDictionary]()
                for hist in self.history {
                    histories.append(hist.getHistoryDictionary())
                }
                UserDefaults.standard.setValue(histories, forKey: kOldHisotries)
                
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                
                if self.history.count > 0 {
                    self.deleteAllBt.isEnabled = true
                    self.tableView.reloadData()
                } else {
                    self.deleteAllBt.isEnabled = false
                }
            }))
            self.present(alert, animated: true)
            
            
        }
    }


    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sharedBrowserVC?.addNewTabSBrowser (
        self.history[indexPath.row].url, transition: .notAnimated) { _ in
            self.dismiss(animated: true, completion: {
                self.sbSettingVC?.dismiss(animated: true, completion: {
                    
                })
            })
        }
        
        

    }

    // MARK: Private Methods

    @objc
    private func _dismiss() {
        dismiss(animated: true)
    }
    
    @objc
    private func _removeAll() {
        if history.count > 0 {
            let alert = UIAlertController(title: "Are you sure to delete all history?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
                
                self.history.removeAll()
                var histories = [NSDictionary]()
                for hist in self.history {
                    histories.append(hist.getHistoryDictionary())
                }
                UserDefaults.standard.setValue(histories, forKey: kOldHisotries)
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                
                self.deleteAllBt.isEnabled = true
                
            }))
            self.present(alert, animated: true)
            
        } else {
            deleteAllBt.isEnabled = false
        }
    }
    
}
