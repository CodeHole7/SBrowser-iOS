//
//  SBProfilesVC.swift
//  SBrowser
//
//  Created by Jin Xu on 12/02/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBProfilesVC: UITableViewController {

    var identities = NSMutableArray()
    var certificates = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.tableFooterView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.isHidden = true
        //tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        navigationItem.title = NSLocalizedString("Profiles", comment: "Scene title")
     //   self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
            tableView.register(UINib(nibName: "tblcell_sbProfiles", bundle: nil), forCellReuseIdentifier: "tblcell_sbProfiles")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        _reloadIdentities()
      //  Getinfo()
    }
    func _reloadIdentities() {
        // Reload our list of identities from the Credentials class.
        identities = NSMutableArray(array: Credentials.shared().identities!)//Credentials.shared().identities!  as! NSMutableArray
        
        
       // certificates = Credentials.shared()?.certificates! as! NSMutableArray
//        if isViewLoaded {
//            self.reloadSections(NSIndexSet(index: kSectionIndexIdentities) as IndexSet, with: .none)
//        }
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2//todo//3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var result = 0
        switch (section) {
            case 0:
                result = self.identities.count;
                if (result == 0) {
                    result = 1;
                }
            
            case 1:
               //todo// result = self.certificates.count;
                if (result == 0) {
                    result = 1;
                }
            
            case 2:
                result = 1;
             
                default:
                    result = 1;
        }
        return result
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {//todo|| section == 1 {
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
                
                let count: Int = self.identities.count
//                if isFiltering ? filtered.count > 0 : data.count > 0 {
//                    for item in isFiltering ? filtered[0] : data[0] {
//                        count += item.storage
//                    }
//                }
                
                title?.text = NSLocalizedString("Identities", comment: "Section header")
                    .localizedUppercase

            } else if section == 1 {

                                
                title?.text = NSLocalizedString("Certificates", comment: "Section header")
                    .localizedUppercase

            }
            
            return view
        }
        
        return nil
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 2{
//            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
//            ?? UITableViewHeaderFooterView(reuseIdentifier: "header")
//            return view
//        }
//        return nil
//    }
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 1 {
//             return 56
//         }
//        if section == 2{
//            return 56
//        }
//      //  super.tableView(<#T##tableView: UITableView##UITableView#>, heightForFooterInSection: <#T##Int#>)
//         return super.tableView(tableView, heightForFooterInSection: section)
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 0{//todo 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "button")
                ?? UITableViewCell(style: .default, reuseIdentifier: "button")

            cell.textLabel?.text = NSLocalizedString("Remove All Profiles", comment: "Button label")

            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            
            return cell
        }
        
//        if !isFiltering && showShortlist && indexPath.row == 10 {
//            if data.count > 11 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "overflowCell")
//                    ?? UITableViewCell(style: .default, reuseIdentifier: "overflowCell")
//
//                cell.textLabel?.textColor = .systemBlue
//                cell.textLabel?.text = NSLocalizedString("Show All Sites", comment: "Button label")
//
//                return cell
//            }
//        }
        let row = indexPath.row;
        
        if indexPath.section == 0  {
            if identities.count == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell")
                    ?? UITableViewCell(style: .value1, reuseIdentifier: "storageCell")
                
                cell.selectionStyle = .none
                cell.textLabel?.text = "No items"
                return cell
                
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tblcell_sbProfiles") as? tblcell_sbProfiles
                  //?? UITableViewCell(style: .value1, reuseIdentifier: "storageCell")
            //  tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
              cell!.selectionStyle = .none
              
               
       
            if identities.count == 0{
                cell?.lbltitle?.text = "No items"
                cell!.accessoryType = .none
            }else{
                var identity: SecIdentity?
                var identityCertificate: SecCertificate?
                var identitySubject: CFString?

                identity = (identities[row] as! SecIdentity)
                _ = SecIdentityCopyCertificate(identity!, &identityCertificate)
                identitySubject = SecCertificateCopySubjectSummary(identityCertificate!)
           //     assert(identitySubject != nil)

                cell?.lbltitle?.text = (identitySubject! as String)
                cell!.accessoryType = .disclosureIndicator
                let dic = Credentials.shared()?.getCertificateTitleinfo(identityCertificate!) as! NSDictionary
                let expiredate = dic["ExpireDate"] as? Date
                let issuarname = dic["issuer"] as? String
                
                let dateFormat1 = DateFormatter()
                dateFormat1.dateFormat = "dd MMMM yyyy"
                let strexpiryDatey = dateFormat1.string(from: expiredate!) // string with yyyy-MM-dd format

                let todayDate = Date()
                if todayDate > expiredate!{
                    cell?.lblexpiredate.text = "Expire since:" + "\(strexpiryDatey)"
                    cell?.lblexpiredate.textColor = UIColor.red
                }else{
                    cell?.lblexpiredate.text = "Expires:" + "\(strexpiryDatey)"
                    cell?.lblexpiredate.textColor = cell?.lblissuedby.textColor
                }
                
                cell?.lblissuedby.text = "Issued by: " + issuarname!
                
  
            }

                
            //    let item = (isFiltering ? filtered[0] : data[0])[indexPath.row]
//                ..//       cell.textLabel?.text = "item1" //item.host
//                var detail = [String]()
//
//                if item.cookies > 0 {
//                    detail.append(String(
//                        format: NSLocalizedString("%@ cookies", comment: "Placeholder contains formatted number"),
//                        Formatter.localize(item.cookies)))
//                }
//
//                if item.storage > 0 {
//                    detail.append(ByteCountFormatter.string(fromByteCount: item.storage, countStyle: .file))
//                }
                
//                cell.detailTextLabel?.text = "555545454545454545554454545545545445545"//detail.joined(separator: ", ")
//            cell.imageView?.image = #imageLiteral(resourceName: "Apple_Settings")
//         cell.detailTextLabel?.frame = CGRect(x: (cell.textLabel?.frame.minX)!, y: (cell.textLabel?.frame.minY)!, width: (cell.detailTextLabel?.frame.width)!, height: (cell.detailTextLabel?.frame.height)!)
            
            return cell!
        } else if indexPath.section == 1  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell")
                ?? UITableViewCell(style: .value1, reuseIdentifier: "storageCell")
            
            cell.selectionStyle = .none
            
            if certificates.count == 0 {
              //  assert(row == 0)
                cell.textLabel?.text = "none"
                cell.textLabel?.font = UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)
            } else {
                var certificate: SecCertificate?
                var subject: CFString?

                certificate = certificates[row] as! SecCertificate
                assert(CFGetTypeID(certificate) == SecCertificateGetTypeID())

                subject = SecCertificateCopySubjectSummary(certificate!)
                assert(subject != nil)

                cell.textLabel?.text = subject! as String
            }
        
            //    cell.textLabel?.text = "item2"
//                let item = (isFiltering ? filtered[1] : data[1])[indexPath.row]
//
//                cell.textLabel?.text = item.host
//
//                var detail = [String]()
//
//                if item.cookies > 0 {
//                    detail.append(String(
//                        format: NSLocalizedString("%@ cookies", comment: "Placeholder contains formatted number"),
//                        Formatter.localize(item.cookies)))
//                }
//
//                if item.storage > 0 {
//                    detail.append(ByteCountFormatter.string(fromByteCount: item.storage, countStyle: .file))
//                }
                
                cell.detailTextLabel?.text = ""//detail.joined(separator: ", ")
            
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return 56
        }
        if identities.count == 0{
            return 56
        }
        return 80
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 56
        }
       return 56
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section > 1/*0*/ || !isFiltering && showShortlist && indexPath.row == 10 && data.count > 11 {
//            return false
//        }
        if indexPath.section == 1{
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            if indexPath.section == 0{
                var identity: SecIdentity?
                
                identity = (identities[indexPath.row] as! SecIdentity)
                let status = Credentials.shared()?.removeIdentity(fromKeychain: identity);
                if status == true{
                    //identities.removeObject(at: indexPath.row)
                 //   _reloadIdentities()
                    Credentials.shared()?.refresh()
                    _reloadIdentities()
                }
              //  tableView.reloadData()
                return
                
                
            }
            
        }
    }
    
//    func removeIdentity(fromKeychain identityRef: SecIdentity?) -> Bool {
//        let publicKeyHash = getPublicKeyHash(from: identityRef)
//        let publicKeyHashBase64 = publicKeyHash?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: (0)))
//
//        var query: [Any? : Any?]? = nil
//        if let kSecValueRef = kSecValueRef as? AnyHashable, let identityRef = identityRef {
//            query = [
//            kSecValueRef: identityRef
//        ]
//        }
//        let status = SecItemDelete(query as? CFDictionary?)
//        if status == errSecSuccess {
//            DDLogInfo("%s: Removing identity from Keychain succeeded.", #function)
//            removeKey(withID: publicKeyHashBase64)
//            return true
//        } else {
//            DDLogError("%s: Removing identity from Keychain failed with OSStatus error code %d!", #function, Int(status))
//            return false
//        }
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                // Must be the show-all cell, others can't be selected.
        if indexPath.section == 0 {//|| indexPath.section == 1 {
            if identities.count == 0{
                return
            }
            let obj = SBProfilesInfoVC()
           // obj.selectedrow = indexPath.row
            obj.isViewFromSettings = true
            obj.identity = (identities[indexPath.row] as! SecIdentity)
            self.navigationController?.pushViewController(
            obj, animated: true)
        }
            // The remove-all cell
        else if indexPath.section > 0{//todo 1 {
            //let secItemClasses =  [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
            //for itemClass in secItemClasses {
                let spec: NSDictionary = [kSecClass: kSecClassIdentity]
                SecItemDelete(spec)
            //}
           // identities.removeAllObjects()
            Credentials.shared()?.refresh()
            _reloadIdentities()
        }
        
        //tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }


    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        let result = UIView()
//
//        // recreate insets from existing ones in the table view
//        let insets = tableView.separatorInset
//        let width = tableView.bounds.width - insets.left - insets.right
//        let sepFrame = CGRect(x: insets.left, y: -0.5, width: width, height: 0.5)
//
//        // create layer with separator, setting color
//        let sep = CALayer()
//        sep.frame = sepFrame
//        sep.backgroundColor = tableView.separatorColor?.cgColor
//        result.layer.addSublayer(sep)
//
//        return result
//    }
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return form[section].header?.viewForSection(form[section], type: .header)
//    }

//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return form[section].footer?.viewForSection(form[section], type:.footer)
//    }
//
////    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        return height(specifiedHeight: form[section].header?.height,
////                      sectionView: self.tableView(tableView, viewForHeaderInSection: section),
////                      sectionTitle: self.tableView(tableView, titleForHeaderInSection: section))
////    }
//
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return height(specifiedHeight: self.footer.height,
//                      sectionView: self.tableView(tableView, viewForFooterInSection: section),
//                      sectionTitle: self.tableView(tableView, titleForFooterInSection: section))
//
//    }
//    func height(specifiedHeight: (() -> CGFloat)?, sectionView: UIView?, sectionTitle: String?) -> CGFloat {
//        if let height = specifiedHeight {
//            return height()
//        }
//
//        if let sectionView = sectionView {
//            let height = sectionView.bounds.height
//
//            if height == 0 {
//                return UITableView.automaticDimension
//            }
//
//            return height
//        }
//
//        if let sectionTitle = sectionTitle,
//            sectionTitle != "" {
//            return UITableView.automaticDimension
//        }
//
//        // Fix for iOS 11+. By returning 0, we ensure that no section header or
//        // footer is shown when self-sizing is enabled (i.e. when
//        // tableView.estimatedSectionHeaderHeight or tableView.estimatedSectionFooterHeight
//        // == UITableView.automaticDimension).
//        if tableView.style == .plain {
//            return 0
//        }
//
//        return UITableView.automaticDimension
//    }
    
    
}
