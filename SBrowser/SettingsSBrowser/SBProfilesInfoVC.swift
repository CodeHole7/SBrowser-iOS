//
//  SBProfilesInfoVC.swift
//  SBrowser
//
//  Created by Jin Xu on 17/02/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBProfilesInfoVC: UITableViewController {

    var identity: SecIdentity?
    var allinfoArr = NSMutableArray()
   // var selectedrow = 0
    var isViewFromSettings = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if isViewFromSettings == false{
            setupnavigationbar()
        }
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.isHidden = true
        Getinfo()
        tableView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        tableView.register(UINib(nibName: "tblcell_sbProfilesInfo", bundle: nil), forCellReuseIdentifier: "tblcell_sbProfilesInfo")
    }
    
    @objc
    class func instantiate() -> UINavigationController {
        let vc = SBProfilesInfoVC()
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .done, target: self, action: #selector(dismsiss_))
        var navigationcontroller =  UINavigationController(rootViewController: vc)
       
        let navigationItem = UINavigationItem()
        navigationItem.title = "Title"
        navigationcontroller.navigationBar.items = [navigationItem]
        return navigationcontroller
    }
    @objc private func dismsiss_() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func ImportCurrentIdentity_() {
        
        
      var err = SecItemAdd([
            kSecValueRef : identity
            ] as CFDictionary, nil)
        if err == errSecDuplicateItem {
            err = 0
        }
        if err != 0 {
            //navigationController?.dismiss(animated: true)
            let alert = UIAlertController(title: "Import Failed", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.dismiss(animated: true)
                return
            }))
            self.present(alert, animated: false, completion: nil)
        }else{
            
            Credentials.shared()?.refresh()
            let alert = UIAlertController(title: "Successfully Imported", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.dismiss(animated: true)
                if shouldRedirectAfterCertImport == true{
                    shouldRedirectAfterCertImport = false
                    //redirect code here
                    rootviewController.searchBar.text = redirecturl!.absoluteString
                    rootviewController.searchBarSearchButtonClicked(rootviewController.searchBar)
                }
                return
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @objc func setupnavigationbar(){
        let leftButton =  UIBarButtonItem(title: "Cancel", style:   .plain, target: self, action: #selector(dismsiss_))
        self.navigationItem.leftBarButtonItem = leftButton;
        
        let rightButton =  UIBarButtonItem(title: "Install", style:   .plain, target: self, action: #selector(ImportCurrentIdentity_))
        self.navigationItem.rightBarButtonItem = rightButton;
        
        
        self.navigationItem.title = "Certificate Information"
//        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:44)) // Offset by 20 pixels vertically to take the status bar into account
//
//        navigationBar.backgroundColor = UIColor.white
//
//
//        // Create a navigation item with a title
//        let navigationItem = UINavigationItem()
//        navigationItem.title = "Title"
//
//        // Create left and right button for navigation item
//         let leftButton =  UIBarButtonItem(title: "Save", style:   .plain, target: self, action: #selector(dismsiss_))
//
//        let rightButton = UIBarButtonItem(title: "Right", style: .plain, target: self, action: nil)
//
//        // Create two buttons for the navigation item
//        navigationItem.leftBarButtonItem = leftButton
//        navigationItem.rightBarButtonItem = rightButton
//
//        // Assign the navigation item to the navigation bar
//        navigationBar.items = [navigationItem]
//
//        // Make the navigation bar a subview of the current view controller
//        self.view.addSubview(navigationBar)
//        self.view.bringSubviewToFront(navigationBar)
        
    }
    func Getinfo(){

        var identityCertificate: SecCertificate?
        var identitySubject: CFString?
        
     
        _ = SecIdentityCopyCertificate(identity!, &identityCertificate)

        
        identitySubject = SecCertificateCopySubjectSummary(identityCertificate!)
        //     assert(identitySubject != nil)
        let certdata = SecCertificateCopyData(identityCertificate!)//sara data h isme
        //   SecCertificateCopyKey(identityCertificate!)
        let publickey = SecCertificateCopyPublicKey(identityCertificate!)
        var serialnumber = SecCertificateCopySerialNumberData(identityCertificate!, nil)
        // var email = SecCertificateCopyEmailAddresses(identityCertificate!, nil)
        SecCertificateCopyNormalizedIssuerSequence(identityCertificate!)
        SecCertificateCopyNormalizedSubjectSequence(identityCertificate!)
     //   SecCertificateCopyPublicKey(identityCertificate!)
        

        
        //SecKeyAlgorithm.init(rawValue: <#T##CFString#>)
        
        let certificateData = SecCertificateCopyData(identityCertificate!) as NSData

        var certificateDataBytes = certificateData.bytes.assumingMemoryBound(to: UInt8.self)
        var emails = [String]()
        var certEmails : CFArray? = nil;
           if SecCertificateCopyEmailAddresses(identityCertificate!, &certEmails) == 0 {
               emails.append(contentsOf: certEmails as! [String]);
           }
        let arr = Credentials.shared()?.getCertificateinfo(identityCertificate!) as! NSArray
         allinfoArr =  NSMutableArray(array: arr)
        if var arr = allinfoArr[0] as? NSMutableArray{
            let dic:NSDictionary = [
            "title" : "Common Name (CN)",
            "item" : "\(identitySubject!)"
            ]

          var newarrray = [dic]
            for i in arr{
                newarrray.append(i as! NSDictionary)
            }
            
            
            allinfoArr[0] = newarrray
        }
   //     allinfoArr = Credentials.shared()?.getCertificateinfo(identityCertificate!) as! NSArray
        
//        if let certificate = SSLCertificate(data: certdata as Data){
//            print(certificate)
//
//        }
        if let certinfo = SSLCertificate(data: certdata as Data){
            allinfoArr.removeAllObjects()
            
            var issuarinfo = certinfo.issuer
            var signaturealgo = certinfo.signatureAlgorithm
            var version = certinfo.version
            var organizationname = certinfo.evOrgName//var
            var serialnumber = certinfo.serialNumber
            var issuedto = certinfo.subject
            var expiredate = certinfo.validityNotAfter
            var releasedate = certinfo.validityNotBefore
            
            
            
            
            
            allinfoArr.add(issuedto)
            
            
            let dateFormat1 = DateFormatter()
            dateFormat1.dateFormat = "MM/dd/yyyy, HH:mm:ss"
            let strToday = dateFormat1.string(from: releasedate!) // string with yyyy-MM-dd format

            let strexpiryDatey = dateFormat1.string(from: expiredate!) // string with yyyy-MM-dd format


            var dic = [
                "Begins On" : "\(strToday)",
                "Expires After" : "\(strexpiryDatey)"
            ]
            allinfoArr.add(dic)
            
            allinfoArr.add(issuarinfo)
            
            
             dic = [
                "Version" : "\(version ?? 0)",
                "Serial Number" : "\(serialnumber ?? "")",
                "Signature Algorithm" : signaturealgo ?? ""
            ]
            
            allinfoArr.add(dic)
            
//            let dic2 = [
//                "title" : "Expires After",
//                "item" : "\(strexpiryDatey)"
//            ]

    //        let validityArr = [dic, dic2]

         //   var dictionary =
           // print(certinfo.nam)
        }
        
       // print(datadictionary)
        print("email\(emails)")
        var error:Unmanaged<CFError>?
        if let cfdata = SecKeyCopyExternalRepresentation(publickey!, &error) {
            if let nsdatatakey = cfdata as? NSData{
                
                let newStr1 = String(data: (nsdatatakey as Data).subdata(in: 0 ..< nsdatatakey.count - 1), encoding: .utf8)
                // unsafe way, provided data is \0-terminated
                let newStr2 = (nsdatatakey as Data).withUnsafeBytes(String.init(utf8String:))
                
                let newdatastring = "\(nsdatatakey)"
                print(newdatastring)
                
                
                print((nsdatatakey as Data).base64EncodedString())
                let signatureString = nsdatatakey.base64EncodedString()
                print(signatureString)
                
                
                do {
                    let dictionary = try convertToDictionary(from: newdatastring)
                    print(dictionary) // prints: ["City": "Paris"]
                } catch {
                    print(error)
                }
                
                
                
                //let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: nsdatatakey as Data) as! [String : Any]
                //print(dictionary)
            }
            
            
          var someString: String? = nil
           if let address = cfdata as? Data {
               someString = String(data: address, encoding: .ascii)
            print(someString)
           }
            
        }
        
        let mirror = Mirror(reflecting: publickey)

        for case let (label?, value) in mirror.children {
            print (label, value)
        }

        
        var dic = SecKeyCopyAttributes(publickey!)
        print(dic)
        
        
        

        let cfdata = SecKeyCopyExternalRepresentation(publickey!, nil)
        print(cfdata)
        

        tableView.reloadData()
    }
    func convertToDictionary(from text: String) throws -> [String: String] {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: String] ?? [:]
    }

    func reloadData(){
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
        return allinfoArr.count//todo//3
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            
            return (allinfoArr[section] as! NSDictionary).count
        }

        override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //    if section == 0 {//todo|| section == 1 {
                let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
                    ?? UITableViewHeaderFooterView(reuseIdentifier: "header")
                
                var title: UILabel? = view.contentView.viewWithTag(666) as? UILabel
                var amount: UILabel? = view.contentView.viewWithTag(667) as? UILabel
                
                if title == nil {
                    title = UILabel()
                    title?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    title?.font = .boldSystemFont(ofSize: 14)
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
                
               // if section == 0 {
                    
                 //   let count: Int = self.datadictionary.count
    //                if isFiltering ? filtered.count > 0 : data.count > 0 {
    //                    for item in isFiltering ? filtered[0] : data[0] {
    //                        count += item.storage
    //                    }
    //                }
            switch section {
            case 0:
                title?.text = NSLocalizedString("Issued To", comment: "Section header")
               // .localizedUppercase
                
            case 1:
                title?.text = NSLocalizedString("Period of Validity", comment: "Section header")
              //  .localizedUppercase
                
            case 2:
                title?.text = NSLocalizedString("Issued By", comment: "Section header")
               // .localizedUppercase
                
            case 3:
                title?.text = NSLocalizedString("Other", comment: "Section header")
               // .localizedUppercase
                
                
            default:
                title?.text = NSLocalizedString("VALIDITY PERIOD", comment: "Section header")
            //    .localizedUppercase
            }
                    

                //}
                
                return view
         //   }
            
            return nil
        }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblcell_sbProfilesInfo") as? tblcell_sbProfilesInfo
        
        cell!.selectionStyle = .none
        let dic = allinfoArr[indexPath.section] as? NSDictionary
        
//        let group = dic[indexPath.section()] as? OrderedDictionary
        var allkeys = dic?.allKeys
        let k = allkeys![indexPath.row]
        
        cell!.lbltitle?.text = k as! String
        cell!.lbldetail?.text = dic?[k ?? ""] as? String

        
        
//        let dic = arr![indexPath.row] as? NSDictionary
//        cell?.lbltitle.text = dic!["title"] as? String
//        cell?.lbldetail.text = dic!["item"] as? String
        return cell!

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 56
        }
        return 56
        
    }

        
     

}
