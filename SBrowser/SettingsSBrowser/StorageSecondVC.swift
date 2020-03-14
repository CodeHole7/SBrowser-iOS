//
//  StorageSecondVC.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class StorageSecondVC: SBSearchTableVC {
    
    struct Item {
        let host: String
        
        var cookies = 0
        
        var storage: Int64 = 0
        
        init(_ host: String) {
            self.host = host
        }
    }
    
    private var filtered = [[Item]]()
    private var showShortlist = true
    
    private var cookieJar: CookieJar? {
        return AppDelegate.shared?.cookieJar
    }
    
    
    func getWKCookies() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.httpCookieStore.getAllCookies({ (cookies) in
            
            var cookiesData = [String: Item]()
            var storageData = [String: Item]()
            
            
            for cookie in cookies {
                var host = cookie.domain
                
                if host.first == "." {
                    host.removeFirst()
                }
                
                var item = cookiesData[host] ?? Item(host)
                item.cookies += 1
                cookiesData[host] = item
            }
            
            let storageD = storageData.map { $1 }.sorted { $0.storage == $1.storage ? $0.cookies > $1.cookies : $0.storage > $1.storage }
            let cookiesD = cookiesData.map { $1 }.sorted { $0.storage == $1.storage ? $0.cookies > $1.cookies : $0.storage > $1.storage }
            
            if self.data.count == 1 {
                for storeD in storageD {
                    self.data[0].append(storeD)
                }
                self.data.append(cookiesD)
            } else if self.data.count == 2 {
                for storeD in storageD {
                    self.data[0].append(storeD)
                }
                for cookD in cookiesD {
                    self.data[1].append(cookD)
                }
            } else {
                self.data.append(storageD)
                self.data.append(cookiesD)
            }
            
            self.tableView.reloadData()
        })
    }
    
    private lazy var data: [[Item]] = {
        var data = [[String: Item]]()
        var cookiesData = [String: Item]()
        var storageData = [String: Item]()
        
        getWKCookies()
        
//        for cookie in getWKCookies() {
//            var host = cookie.domain
//
//            if host.first == "." {
//                host.removeFirst()
//            }
//
//            var item = cookiesData[host] ?? Item(host)
//            item.cookies += 1
//            cookiesData[host] = item
//        }
        
        if let cookies = cookieJar?.cookieStorage.cookies {
            for cookie in cookies {
                var host = cookie.domain
                
                if host.first == "." {
                    host.removeFirst()
                }
                
                var item = cookiesData[host] ?? Item(host)
                item.cookies += 1
                cookiesData[host] = item
            }
        }
        
        //data.append(cookiesData)
        
        if let files = cookieJar?.localStorageFiles() {
            for item in files {
                if let filepath = item.key as? String,
                    let host = item.value as? String {
                    
                    var item = storageData[host] ?? Item(host)
                    item.storage += (size(filepath) ?? 0)
                    storageData[host] = item
                }
            }
        }
        
        //data.append(storageData)
        
        //return data.map { $1 }.sorted { $0.storage == $1.storage ? $0.cookies > $1.cookies : $0.storage > $1.storage }
        let cookiesD = cookiesData.map { $1 }.sorted { $0.storage == $1.storage ? $0.cookies > $1.cookies : $0.storage > $1.storage }
        let storageD = storageData.map { $1 }.sorted { $0.storage == $1.storage ? $0.cookies > $1.cookies : $0.storage > $1.storage }
        
        var fData = [[Item]]()
        fData.append(storageD)//should be at first
        fData.append(cookiesD)//should be at second
        
        return fData
    }()
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Cookies and Local Storage", comment: "Scene title")
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return isFiltering ? 1 : 2//vishnu
        return isFiltering ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return isFiltering ? filtered.count : (showShortlist && data.count > 11 ? 11 : data.count)
//        }
        
        if section == 0 {
            var count = 0
            if data.count > 0 {
                count = data[0].filter { (itm) -> Bool in
                    return itm.storage > 0
                }.count
            }
            var filterCount = 0
            if filtered.count > 0 {
                filterCount = filtered[0].filter { (itm) -> Bool in
                    return itm.storage > 0
                }.count
            }
            return isFiltering ? filterCount : (showShortlist && count > 11 ? 11 : count)
        } else if section == 1 {
            var count = 0
            if data.count > 1 {
                count = data[1].filter { (itm) -> Bool in
                    return itm.cookies > 0
                }.count
            }
          
            var filterCount = 0
            if filtered.count > 1 {
                filterCount = filtered[1].filter { (itm) -> Bool in
                    return itm.cookies > 0
                }.count
            }
            return isFiltering ? filterCount : (showShortlist && count > 11 ? 11 : count)
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 56
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
                ?? UITableViewHeaderFooterView(reuseIdentifier: "header")
            
            var title: UILabel? = view.contentView.viewWithTag(666) as? UILabel
            var amount: UILabel? = view.contentView.viewWithTag(667) as? UILabel
            
            if title == nil {
                title = UILabel()
                title?.textColor = UIColor(red: 0.427451, green: 0.427451, blue: 0.447059, alpha: 1)
                title?.font = .systemFont(ofSize: 14)
                title?.translatesAutoresizingMaskIntoConstraints = false
                title?.tag = 666
                
                view.contentView.addSubview(title!)
                title?.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor, constant: 16).isActive = true
                title?.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor, constant: -8).isActive = true
                
                amount = UILabel()
                amount?.textColor = title?.textColor
                amount?.font = title?.font
                amount?.translatesAutoresizingMaskIntoConstraints = false
                amount?.tag = 667
                
                view.contentView.addSubview(amount!)
                amount?.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor, constant: -16).isActive = true
                amount?.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor, constant: -8).isActive = true
            }
            
            if section == 0 {
                
                var count: Int64 = 0
                if isFiltering ? filtered.count > 0 : data.count > 0 {
                    for item in isFiltering ? filtered[0] : data[0] {
                        count += item.storage
                    }
                }
                
                title?.text = NSLocalizedString("Local Storage", comment: "Section header")
                    .localizedUppercase
                
                amount?.text = ByteCountFormatter
                    .string(fromByteCount: count, countStyle: .file)
            } else if section == 1 {
                
                var count: Int = 0
                
                if isFiltering ? filtered.count > 1 : data.count > 1 {
                    for item in isFiltering ? filtered[1] : data[1] {
                        count += item.cookies
                    }
                }
                                
                title?.text = NSLocalizedString("Cookies", comment: "Section header")
                    .localizedUppercase
                
                amount?.text = "\(count)"
            }
            
            return view
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 1 { //0 {//vishnu
            let cell = tableView.dequeueReusableCell(withIdentifier: "button")
                ?? UITableViewCell(style: .default, reuseIdentifier: "button")
            
            cell.textLabel?.text = NSLocalizedString("Remove All Local Storage", comment: "Button label")
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            
            return cell
        }
        
        if !isFiltering && showShortlist && indexPath.row == 10 {
            if data.count > 11 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "overflowCell")
                    ?? UITableViewCell(style: .default, reuseIdentifier: "overflowCell")
                
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.text = NSLocalizedString("Show All Sites", comment: "Button label")
                
                return cell
            }
        }
        
        if indexPath.section == 0 && (isFiltering ? filtered.count > 0 : data.count > 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell")
                ?? UITableViewCell(style: .value1, reuseIdentifier: "storageCell")
            
            cell.selectionStyle = .none
            
            if (isFiltering ? filtered[0].count > indexPath.row : data[0].count > indexPath.row) {
                
                let item = (isFiltering ? filtered[0] : data[0])[indexPath.row]
                cell.textLabel?.text = item.host
                var detail = [String]()
                
                if item.cookies > 0 {
                    detail.append(String(
                        format: NSLocalizedString("%@ cookies", comment: "Placeholder contains formatted number"),
                        Formatter.localize(item.cookies)))
                }
                
                if item.storage > 0 {
                    detail.append(ByteCountFormatter.string(fromByteCount: item.storage, countStyle: .file))
                }
                
                cell.detailTextLabel?.text = detail.joined(separator: ", ")
                
            }
            
            return cell
        } else if indexPath.section == 1 && (isFiltering ? filtered.count > 1 : data.count > 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell")
                ?? UITableViewCell(style: .value1, reuseIdentifier: "storageCell")
            
            cell.selectionStyle = .none
            
            if (isFiltering ? filtered[1].count > indexPath.row : data[1].count > indexPath.row) {
                
                let item = (isFiltering ? filtered[1] : data[1])[indexPath.row]
                
                cell.textLabel?.text = item.host
                
                var detail = [String]()
                
                if item.cookies > 0 {
                    detail.append(String(
                        format: NSLocalizedString("%@ cookies", comment: "Placeholder contains formatted number"),
                        Formatter.localize(item.cookies)))
                }
                
                if item.storage > 0 {
                    detail.append(ByteCountFormatter.string(fromByteCount: item.storage, countStyle: .file))
                }
                
                cell.detailTextLabel?.text = detail.joined(separator: ", ")
            }
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section > 1/*0*/ || !isFiltering && showShortlist && indexPath.row == 10 && data.count > 11 {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if indexPath.section == 0 && (isFiltering ? filtered.count > 0 : data.count > 0) {
                
                if (isFiltering ? filtered[0].count > indexPath.row : data[0].count > indexPath.row) {
                    
                    let host = (isFiltering ? filtered[0] : data[0])[indexPath.row].host
                    
                    cookieJar?.clearAllData(forHost: host)
                    
                    if isFiltering {
                        filtered[0].remove(at: indexPath.row)
                        
                        data[0].removeAll { $0.host == host }
                    }
                    else {
                        data[0].remove(at: indexPath.row)
                    }
                    
                    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
            } else if indexPath.section == 1 && (isFiltering ? filtered.count > 1 : data.count > 1) {
                
                if (isFiltering ? filtered[1].count > indexPath.row : data[1].count > indexPath.row) {
                    
                    let host = (isFiltering ? filtered[1] : data[1])[indexPath.row].host
                    
                    cookieJar?.clearAllData(forHost: host)
                    
                    if isFiltering {
                        filtered[1].remove(at: indexPath.row)
                        
                        data[1].removeAll { $0.host == host }
                    }
                    else {
                        data[1].remove(at: indexPath.row)
                    }
                    
                    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
            }
            
        }
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Must be the show-all cell, others can't be selected.
        if indexPath.section == 0 || indexPath.section == 1 {
            showShortlist = false
        }
            // The remove-all cell
        else if indexPath.section > 1 {
            cookieJar?.clearAllNonWhitelistedData()
            
            
            data.removeAll()
        }
        
        //tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: UISearchResultsUpdating
    
    override func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchText {
            //filtered = data.filter() { $0.host.lowercased().contains(searchText) }
            
            var pos1 = [Item]()
            var pos2 = [Item]()
            
            if data.count == 1 {
                pos1 = data[0].filter() { $0.host.lowercased().contains(searchText) }
            } else if data.count == 2 {
                pos1 = data[0].filter() { $0.host.lowercased().contains(searchText) }
                pos2 = data[1].filter() { $0.host.lowercased().contains(searchText) }
            }
                        
            if filtered.count == 1 {
                filtered[0] = pos1
            } else if filtered.count == 2 {
                filtered[0] = pos1
                filtered[1] = pos2
            } else {
                filtered.append(pos1)
                filtered.append(pos2)
            }
        }
        else {
            filtered.removeAll()
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: Private Methods
    
    /**
     Get size in byte of a given file.
     
     - parameter filepath: The path to the file.
     - returns: File size in bytes.
     */
    private func size(_ filepath: String?) -> Int64? {
        if let filepath = filepath,
            let attr = try? FileManager.default.attributesOfItem(atPath: filepath) {
            return (attr[.size] as? NSNumber)?.int64Value
        }
        
        return nil
    }
}

