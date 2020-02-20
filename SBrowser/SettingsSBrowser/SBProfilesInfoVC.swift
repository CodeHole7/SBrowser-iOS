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
    var selectedrow = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        Getinfo()
    }
    func Getinfo(){

        var identityCertificate: SecCertificate?
        var identitySubject: CFString?
        
     
        _ = SecIdentityCopyCertificate(identity!, &identityCertificate)

        
        identitySubject = SecCertificateCopySubjectSummary(identityCertificate!)
        //     assert(identitySubject != nil)
        SecCertificateCopyData(identityCertificate!)//sara data h isme
        //   SecCertificateCopyKey(identityCertificate!)
        let publickey = SecCertificateCopyPublicKey(identityCertificate!)
        var serialnumber = SecCertificateCopySerialNumberData(identityCertificate!, nil)
        // var email = SecCertificateCopyEmailAddresses(identityCertificate!, nil)
        SecCertificateCopyNormalizedIssuerSequence(identityCertificate!)
        SecCertificateCopyNormalizedSubjectSequence(identityCertificate!)
     //   SecCertificateCopyPublicKey(identityCertificate!)
        

        
        
        
        let certificateData = SecCertificateCopyData(identityCertificate!) as NSData

        var certificateDataBytes = certificateData.bytes.assumingMemoryBound(to: UInt8.self)
        var emails = [String]()
        var certEmails : CFArray? = nil;
           if SecCertificateCopyEmailAddresses(identityCertificate!, &certEmails) == 0 {
               emails.append(contentsOf: certEmails as! [String]);
           }
        let arr = Credentials.shared()?.getCertificateinfo(identityCertificate!) as! NSArray
         allinfoArr =  NSMutableArray(array: arr)
   //     allinfoArr = Credentials.shared()?.getCertificateinfo(identityCertificate!) as! NSArray
        
        
        
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
            
            return (allinfoArr[section] as! NSArray).count
        }

        override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //    if section == 0 {//todo|| section == 1 {
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
                
               // if section == 0 {
                    
                 //   let count: Int = self.datadictionary.count
    //                if isFiltering ? filtered.count > 0 : data.count > 0 {
    //                    for item in isFiltering ? filtered[0] : data[0] {
    //                        count += item.storage
    //                    }
    //                }
            switch section {
            case 0:
                title?.text = NSLocalizedString("SUBJECT NAME", comment: "Section header")
                .localizedUppercase
                
            case 1:
                title?.text = NSLocalizedString("ISUER NAME", comment: "Section header")
                .localizedUppercase
                
            case 2:
                title?.text = NSLocalizedString("SERIAL NUMBER", comment: "Section header")
                .localizedUppercase
                
            case 3:
                title?.text = NSLocalizedString("VALIDITY PERIOD", comment: "Section header")
                .localizedUppercase
                
                
            default:
                title?.text = NSLocalizedString("VALIDITY PERIOD", comment: "Section header")
                .localizedUppercase
            }
                    

                //}
                
                return view
         //   }
            
            return nil
        }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let row = indexPath.row;
        
      //  if indexPath.section == 0  {//
            let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell")
                ?? UITableViewCell(style: .value1, reuseIdentifier: "storageCell")
            
            cell.selectionStyle = .none

            let arr = allinfoArr[indexPath.section] as? NSArray
            let dic = arr![indexPath.row] as? NSDictionary
            
            cell.textLabel?.text = dic!["title"] as? String

            cell.detailTextLabel?.text = dic!["item"] as? String

            return cell
        //}
        
        return UITableViewCell()
        
    }
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if section == 0 || section == 1 {
                return 56
            }
           return 56
      
        }

        
     

}
