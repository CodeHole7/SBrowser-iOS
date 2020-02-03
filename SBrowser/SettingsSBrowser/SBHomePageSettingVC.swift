//
//  SBHomePageSettingVC.swift
//  SBrowser
//
//  Created by JinXu on 30/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBHomePageSettingVC: UIViewController {
    
    @IBOutlet weak var lblCurrentHomepageTitle: UILabel!
    @IBOutlet weak var btnDefaultHomepage: RadioButton!
    @IBOutlet weak var btnCustomHomepage: RadioButton!
    @IBOutlet weak var lblDefaultHomepage: UILabel!
    @IBOutlet weak var lblCustomHomepage: UILabel!
    @IBOutlet weak var txtFieldCustomHomepage: UITextField!
    @IBOutlet weak var lblValueCurrentPage: UILabel!
    @IBOutlet weak var btnUseCurrentPage: RadioButton!
    @IBOutlet weak var btnAddCustomHomepage: RadioButton!
    @IBOutlet weak var btnSet: UIButton!
    
    var buttonsMain : [RadioButton]?
    var buttonsSub : [RadioButton]?
    
    
    @objc
    class func instantiate() -> UINavigationController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SBHomePageSettingVC")
        return UINavigationController(rootViewController: vc)
    }
    
    private lazy var doneBt = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(_dismiss))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = NSLocalizedString("History", comment: "")
        navigationItem.leftBarButtonItem = doneBt
        
        buttonsMain = [btnDefaultHomepage, btnCustomHomepage]
        buttonsSub = [btnUseCurrentPage, btnAddCustomHomepage]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateHomePage()
    }
    
    
    func updateHomePage() {
        if let defaultHomePage = UserDefaults.standard.value(forKey: kHomePage) as? String {
            if defaultHomePage == "default" {
                //btnDefaultHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
                //btnCustomHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
                
                txtFieldCustomHomepage.text = ""
                lblValueCurrentPage.text = ""
                btnSet.isEnabled = false
                btnAddCustomHomepage.isEnabled = false
                btnUseCurrentPage.isEnabled = false
                txtFieldCustomHomepage.isEnabled = false
            } else {
               // btnCustomHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
                //btnDefaultHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
                
                txtFieldCustomHomepage.text = ""
                lblValueCurrentPage.text = defaultHomePage
                btnSet.isEnabled = true
                btnAddCustomHomepage.isEnabled = true
                btnUseCurrentPage.isEnabled = true
                txtFieldCustomHomepage.isEnabled = true
            }
        } else {
            //btnDefaultHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
            //btnCustomHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
            
            txtFieldCustomHomepage.text = ""
            lblValueCurrentPage.text = ""
            btnSet.isEnabled = false
            btnAddCustomHomepage.isEnabled = false
            btnUseCurrentPage.isEnabled = false
            txtFieldCustomHomepage.isEnabled = false
        }
    }
    
    
    
    
    
    @IBAction func clickedDefaultHomepage(_ sender: RadioButton) {
        UserDefaults.standard.setValue("default", forKey: kHomePage)
        
        updateHomePage()
        
        buttonsMain?.forEach({ $0.isSelected = false})
        sender.isSelected = true
    }
    
    @IBAction func clickedCustomHomepage(_ sender: RadioButton) {
        
        //btnCustomHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
        //btnDefaultHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
        
        txtFieldCustomHomepage.text = ""
        if let defaultHomePage = UserDefaults.standard.value(forKey: kHomePage) as? String {
            lblValueCurrentPage.text = defaultHomePage
        }
        btnSet.isEnabled = true
        btnAddCustomHomepage.isEnabled = true
        btnUseCurrentPage.isEnabled = true
        txtFieldCustomHomepage.isEnabled = true
        
      //  updateHomePage()
        
        buttonsMain?.forEach({ $0.isSelected = false})
        sender.isSelected = true
    }
    
    @IBAction func clickedUseCurrentPage(_ sender: RadioButton) {
        let string = sharedBrowserVC?.currentTab?.url.absoluteString
        lblValueCurrentPage.text = string
        UserDefaults.standard.setValue(string, forKey: kHomePage)
        
        buttonsSub?.forEach({ $0.isSelected = false})
        sender.isSelected = true
    }
    
    @IBAction func clickedAddCustomHomepage(_ sender: RadioButton) {
        buttonsSub?.forEach({ $0.isSelected = false})
        sender.isSelected = true
    }
    
    @IBAction func clickedSet(_ sender: UIButton) {
        
        var string = ""
        if let txtFldValue = txtFieldCustomHomepage.text {
            string = txtFldValue
        }
        
        if string != "" {
            lblValueCurrentPage.text = string
            UserDefaults.standard.setValue(string, forKey: kHomePage)
        }
        
    }
    
    
    func isDefaultnCustomSelection(isDefault: Bool) {
        buttonsMain?.forEach({ $0.isSelected = false})
        
        if isDefault {
            
            btnDefaultHomepage.isSelected = true
            isCustomSubSelection(isUseCurrentPage: true, isAllDisable: true)
        } else {
            //isCustomSubSelection(isUseCurrentPage: Bool, isAllDisable: Bool)
            
            btnCustomHomepage.isSelected = true
        }
    }
    
    func isCustomSubSelection(isUseCurrentPage: Bool, isAllDisable: Bool) {
        buttonsSub?.forEach({ $0.isSelected = false})
        
        btnUseCurrentPage.isEnabled = false
        btnAddCustomHomepage.isEnabled = false
        btnSet.isEnabled = false
        txtFieldCustomHomepage.isEnabled = false
        lblValueCurrentPage.text = ""
        
        if isAllDisable {
            return
        }
        
        btnUseCurrentPage.isEnabled = true
        btnAddCustomHomepage.isEnabled = true
        
        if isUseCurrentPage {
            
            btnUseCurrentPage.isSelected = true
            return
        } else {
            
            btnSet.isEnabled = true
            txtFieldCustomHomepage.isEnabled = true
            btnAddCustomHomepage.isSelected = true
        }
    }
    
    
    // MARK: Private Methods
    @objc
    private func _dismiss() {
        dismiss(animated: true)
    }
    
    

}
