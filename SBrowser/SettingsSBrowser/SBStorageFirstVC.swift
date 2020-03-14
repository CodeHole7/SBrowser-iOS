//
//  SBStorageFirstVC.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka

class SBStorageFirstVC: SBFixedFormVC {

    /**
    We need a day beginning at 00:00 of the current day with the user's timezone.

    Otherwise, we will see timezone-corrected time intervals or current time.
    */
    private lazy var reference: Date? = {
        return Calendar.current.date(from:
            Calendar.current.dateComponents(Set([.timeZone, .year, .month, .day]), from: Date()))
    }()

    private lazy var intervalRow = SwitchRow() {//LabelRow() {
        $0.title = NSLocalizedString("Auto-Sweep Interval", comment: "Option title")
        $0.cell.textLabel?.numberOfLines = 0
        $0.cell.switchControl.onTintColor = .accent
        $0.value = isAutoSweepEnabled

    }
    private lazy var CountDownRow = CountDownPickerRow() {//LabelRow() {
        if let reference = reference {
            let date = Date(timeInterval: SettingsSBrowser.cookieAutoSweepInterval, since: reference)
            $0.value = date
           // $0.hidden = Condition(booleanLiteral: !isAutoSweepEnabled)
            $0.cell.isUserInteractionEnabled = isAutoSweepEnabled
            updateIntervalRow(date)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let val = UserDefaults.standard.object(forKey: "isAutoSweepEnabled") as? Bool{
            isAutoSweepEnabled = val
        }else{
            UserDefaults.standard.set(false, forKey: "isAutoSweepEnabled")
            isAutoSweepEnabled = false
        }
        
        navigationItem.title = NSLocalizedString("Cookies and Local Storage", comment: "Scene title")
        makeTable()

    }
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0{
//            return 1
//        }
//        if isAutoSweepEnabled == true{
//            return 2
//        }else{
//            return 1
//        }
//    }
    @objc func makeTable(){
//        if isAutoSweepEnabled == true{
      //  form.removeAll()
            form
                +++ LabelRow() {
                    $0.title = NSLocalizedString("Cookies and Local Storage", comment: "Option title")
                    $0.cell.textLabel?.numberOfLines = 0
                    $0.cell.accessoryType = .disclosureIndicator
                    $0.cell.selectionStyle = .default
                }
                .onCellSelection { _, _ in
                    self.navigationController?.pushViewController(
                        StorageSecondVC(), animated: true)
                }
                
                +++ Section(footer: NSLocalizedString(
                    "Cookies and local storage data from non-whitelisted hosts will be cleared even from open tabs after not being accessed for this many minutes.",
                    comment: "Option description"))
                
                <<< intervalRow
                    .onChange { row in
                        if let value = row.value {
                            UserDefaults.standard.set(value, forKey: "isAutoSweepEnabled")
                            isAutoSweepEnabled = value
                          //  self.tableView.reloadData()
                            let cell = self.tableView.cellForRow(at: IndexPath(item: 1, section: 1))
                            cell?.isUserInteractionEnabled = value
                           // cell?.isHidden = !value
                            
//                            if value == true{
//                                let view = self.tableView.footerView(forSection: 1)
//                                view?.textLabel?.text = "Cookies and local storage data from non-whitelisted hosts will be cleared even from open tabs after not being accessed for this many minutes."
//                            }else{
//                                let view = self.tableView.footerView(forSection: 1)
//                                view?.textLabel?.text = ""
//                            }
                            
                            
                         //   self.tableView.reloadData()
                           // self.makeTable()
                        }
                }
                
                <<< CountDownRow
                    .onChange { row in
                        if let value = row.value, let reference = self.reference {
                            SettingsSBrowser.cookieAutoSweepInterval = value.timeIntervalSinceReferenceDate - reference.timeIntervalSinceReferenceDate
                            
                            self.updateIntervalRow(value)
                        }
            }
//        }else{
//            form
//                +++ LabelRow() {
//                    $0.title = NSLocalizedString("Cookies and Local Storage", comment: "Option title")
//                    $0.cell.textLabel?.numberOfLines = 0
//                    $0.cell.accessoryType = .disclosureIndicator
//                    $0.cell.selectionStyle = .default
//                }
//                .onCellSelection { _, _ in
//                    self.navigationController?.pushViewController(
//                        StorageSecondVC(), animated: true)
//                }
//
//                +++ Section(footer: NSLocalizedString(
//                    "Cookies and local storage data from non-whitelisted hosts will be cleared even from open tabs after not being accessed for this many minutes.",
//                    comment: "Option description"))
//
//                <<< intervalRow
//                    .onChange { row in
//                        if let value = row.value {
//                            UserDefaults.standard.set(value, forKey: "isAutoSweepEnabled")
//                            self.makeTable()
//                        }
//                }
//
////                <<< CountDownRow
////                    .onChange { row in
////                        if let value = row.value, let reference = self.reference {
////                            SettingsSBrowser.cookieAutoSweepInterval = value.timeIntervalSinceReferenceDate - reference.timeIntervalSinceReferenceDate
////
////                            self.updateIntervalRow(value)
////                        }
////                }
//        }
        
        
        
        
      
           
       
//            let cell = self.tableView.cellForRow(at: IndexPath(item: 1, section: 1))
//
//            cell?.isHidden = !isAutoSweepEnabled
//
//            if isAutoSweepEnabled == true{
//                let view = self.tableView.footerView(forSection: 1)
//                view?.textLabel?.text = "Cookies and local storage data from non-whitelisted hosts will be cleared even from open tabs after not being accessed for this many minutes."
//            }else{
//                let view = self.tableView.footerView(forSection: 1)
//                view?.textLabel?.text = ""
//            }
            
            
            
           // self.makeTable()
        
        
        
        
    }
    private func updateIntervalRow(_ date: Date) {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)

        //self.intervalRow.value = DateComponentsFormatter.localizedString(
          //  from: dateComponents, unitsStyle: .abbreviated)?.replacingOccurrences(of: ",", with: "")//ps
      
        let value = DateComponentsFormatter.localizedString(from: dateComponents, unitsStyle: .abbreviated)?.replacingOccurrences(of: ",", with: "")//ps
        
        self.intervalRow.title = NSLocalizedString("Auto-Sweep Interval   (\(value!))", comment: "Option title")//ps
        self.intervalRow.updateCell()
    }
}
