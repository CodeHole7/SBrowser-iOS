//
//  SBHomePageSettingVC.swift
//  SBrowser
//
//  Created by Jin Xu on 30/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBHomePageSettingVC: UIViewController {
    
    @IBOutlet weak var segmentcontrol: UISegmentedControl!
  //  @IBOutlet weak var lblCurrentHomepageTitle: UILabel!
//    @IBOutlet weak var btnDefaultHomepage: RadioButton!
//    @IBOutlet weak var btnCustomHomepage: RadioButton!
//    @IBOutlet weak var lblDefaultHomepage: UILabel!
//    @IBOutlet weak var lblCustomHomepage: UILabel!
//    @IBOutlet weak var txtFieldCustomHomepage: UITextField!
    //@IBOutlet weak var lblValueCurrentPage: UILabel!
//    @IBOutlet weak var btnUseCurrentPage: UIButton!
//    @IBOutlet weak var btnAddCustomHomepage: UIButton!
   // @IBOutlet weak var btnSet: UIButton!
    @IBOutlet weak var textfieldUrl: UITextField!
    
 //   var buttonsMain : [RadioButton]?
    
    
    @objc
    class func instantiate() -> UINavigationController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SBHomePageSettingVC")
        return UINavigationController(rootViewController: vc)
    }
    
    private lazy var doneBt = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(_dismiss))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textfieldUrl.leftView = paddingView
        textfieldUrl.leftViewMode = .always
        textfieldUrl.backgroundColor = UIColor.white
        textfieldUrl.layer.borderWidth = 1
        textfieldUrl.layer.borderColor = UIColor.lightGray.cgColor
        
        if #available(iOS 13.0, *) {
//            var selectedcolor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
//           segmentcontrol.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
//           segmentcontrol.selectedSegmentTintColor = selectedcolor
//            segmentcontrol.setTitleTextAttributes([.foregroundColor: selectedcolor], for: .normal)
            
        }
        segmentcontrol.iOSStyle()
        // Do any additional setup after loading the view.
        navigationItem.title = NSLocalizedString("Homepage", comment: "")
      //  navigationItem.leftBarButtonItem = doneBt
        
      //  buttonsMain = [btnDefaultHomepage, btnCustomHomepage]
    }
    @IBAction func segmentControlClicked(_ sender: Any) {
        if segmentcontrol.selectedSegmentIndex == 0{
                print("0")
            isDefaultnCustomSelection(isDefault: true, isUseCurrentPage: false)
            
        }else if segmentcontrol.selectedSegmentIndex == 1{
            print("1")
            isDefaultnCustomSelection(isDefault: false, isUseCurrentPage: true)
        }else if segmentcontrol.selectedSegmentIndex == 2{
            isDefaultnCustomSelection(isDefault: false, isUseCurrentPage: false)
            print("2")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //updateHomePage()
        if let defaultHomePage = UserDefaults.standard.value(forKey: kHomePage) as? String {
            if defaultHomePage == "default" {
                isDefaultnCustomSelection(isDefault: true, isUseCurrentPage: false, isFirst: true)
            } else {
                isDefaultnCustomSelection(isDefault: false, isUseCurrentPage: true, isFirst: true)
            }
        } else {
            isDefaultnCustomSelection(isDefault: true, isUseCurrentPage: false, isFirst: true)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        var string = textfieldUrl.text ?? ""
        
        if (string as NSString).lastPathComponent != "newTab.html"{
            if  string == "https://www.sbrowser.app"{
                UserDefaults.standard.setValue("default", forKey: kHomePage)
            }else{
                
                
                
                if string.hasPrefix("http://") || string.hasPrefix("https://") {
                    UserDefaults.standard.setValue(string, forKey: kHomePage)
                } else {
                    string = "http://\(string)"
                    UserDefaults.standard.setValue(string, forKey: kHomePage)
                }
                
            }
        }else{
           // if  string == "https://www.sbrowser.app"{
                UserDefaults.standard.setValue("default", forKey: kHomePage)
//            }else{
//                UserDefaults.standard.setValue(string, forKey: kHomePage)
//            }
        }
        
        
    }
    
//    func updateHomePage() {
//
//        if let defaultHomePage = UserDefaults.standard.value(forKey: kHomePage) as? String {
//            if defaultHomePage == "default" {
//                //btnDefaultHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
//                //btnCustomHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
//
////                txtFieldCustomHomepage.text = ""
//                lblValueCurrentPage.text = ""
////                btnSet.isEnabled = false
////                btnAddCustomHomepage.isEnabled = false
////                btnUseCurrentPage.isEnabled = false
////                txtFieldCustomHomepage.isEnabled = false
//            } else {
//               // btnCustomHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
//                //btnDefaultHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
//
//  //              txtFieldCustomHomepage.text = ""
//                lblValueCurrentPage.text = defaultHomePage
////                btnSet.isEnabled = true
////                btnAddCustomHomepage.isEnabled = true
////                btnUseCurrentPage.isEnabled = true
////                txtFieldCustomHomepage.isEnabled = true
//            }
//        } else {
//            //btnDefaultHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
//            //btnCustomHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
//
//  //          txtFieldCustomHomepage.text = ""
//            lblValueCurrentPage.text = ""
////            btnSet.isEnabled = false
////            btnAddCustomHomepage.isEnabled = false
////            btnUseCurrentPage.isEnabled = false
////            txtFieldCustomHomepage.isEnabled = false
//        }
//    }
    
    
    
    
    
    @IBAction func clickedDefaultHomepage(_ sender: RadioButton) {
//        UserDefaults.standard.setValue("default", forKey: kHomePage)
//
//        updateHomePage()
//
//        buttonsMain?.forEach({ $0.isSelected = false})
//        sender.isSelected = true
        
        isDefaultnCustomSelection(isDefault: true, isUseCurrentPage: false)
        
    }
    
    @IBAction func clickedCustomHomepage(_ sender: RadioButton) {
        
        //btnCustomHomepage.setImage(UIImage(named: "radioSelected.png"), for: .normal)
        //btnDefaultHomepage.setImage(UIImage(named: "radioUnselected.png"), for: .normal)
        
//        txtFieldCustomHomepage.text = ""
//        if let defaultHomePage = UserDefaults.standard.value(forKey: kHomePage) as? String {
//            lblValueCurrentPage.text = defaultHomePage
//        }
//        btnSet.isEnabled = true
//        btnAddCustomHomepage.isEnabled = true
//        btnUseCurrentPage.isEnabled = true
//        txtFieldCustomHomepage.isEnabled = true
//
//        updateHomePage()
//
//        buttonsMain?.forEach({ $0.isSelected = false})
//        sender.isSelected = true
        
        isDefaultnCustomSelection(isDefault: false, isUseCurrentPage: true)
    }
    
    @IBAction func clickedUseCurrentPage(_ sender: RadioButton) {
//        let string = sharedBrowserVC?.currentTab?.url.absoluteString
//        lblValueCurrentPage.text = string
//        UserDefaults.standard.setValue(string, forKey: kHomePage)
//
//        buttonsSub?.forEach({ $0.isSelected = false})
//        sender.isSelected = true
        
        isDefaultnCustomSelection(isDefault: false, isUseCurrentPage: true)
    }
    
    @IBAction func clickedAddCustomHomepage(_ sender: RadioButton) {
//        buttonsSub?.forEach({ $0.isSelected = false})
//        sender.isSelected = true
        
        isDefaultnCustomSelection(isDefault: false, isUseCurrentPage: false)
    }
    
//    @IBAction func clickedSet(_ sender: UIButton) {
//
//        var string = ""
//        if let txtFldValue = txtFieldCustomHomepage.text {
//            string = txtFldValue
//        }
//
//        if string != "" {
//            lblValueCurrentPage.text = string
//            UserDefaults.standard.setValue(string, forKey: kHomePage)
//        }
//
//    }
    
    
    func isDefaultnCustomSelection(isDefault: Bool, isUseCurrentPage: Bool, isFirst: Bool = false) {
     //   buttonsMain?.forEach({ $0.isSelected = false})
        
        if isDefault {
            
            UserDefaults.standard.setValue("default", forKey: kHomePage)
          //  btnDefaultHomepage.isSelected = true
            isCustomSubSelection(isUseCurrentPage: true, isAllDisable: true, isFirst: isFirst)
            textfieldUrl.text = "https://www.sbrowser.app"
        } else {
            
            isCustomSubSelection(isUseCurrentPage: isUseCurrentPage, isAllDisable: false, isFirst: isFirst)
            //btnCustomHomepage.isSelected = true
        }
    }
    
    func isCustomSubSelection(isUseCurrentPage: Bool, isAllDisable: Bool, isFirst: Bool) {
             
//        btnUseCurrentPage.isEnabled = false
//        btnAddCustomHomepage.isEnabled = false
     //   btnSet.isHidden = true
      //  txtFieldCustomHomepage.isHidden = true
      //  lblValueCurrentPage.text = ""
        
        if isAllDisable {
            return
        }
        
//        btnUseCurrentPage.isEnabled = true
//        btnAddCustomHomepage.isEnabled = true
        
        if isUseCurrentPage {
            
            if isFirst {
                
                if let defaultHomePage = UserDefaults.standard.value(forKey: kHomePage) as? String {
                    if defaultHomePage != "default" {
                        //lblValueCurrentPage.text = defaultHomePage
                        if (defaultHomePage as NSString).lastPathComponent != "newTab.html"{
                            textfieldUrl.text = defaultHomePage
                        }else{
                            textfieldUrl.text = "https://www.sbrowser.app"
                        }
                        //textfieldUrl.text = defaultHomePage
                    }
                }
                
            } else {
                let string = sharedBrowserVC?.currentTab?.url.absoluteString
               // lblValueCurrentPage.text = string
                if (string! as NSString).lastPathComponent != "newTab.html"{
                    textfieldUrl.text = string
                }else{
                    textfieldUrl.text = "https://www.sbrowser.app"
                }
                
                UserDefaults.standard.setValue(string, forKey: kHomePage)
            }
            
          //  btnUseCurrentPage.isSelected = true
            return
        } else {
            
          //  btnSet.isHidden = false
         //   txtFieldCustomHomepage.isHidden = false
         //   btnAddCustomHomepage.isSelected = true
            
        }
    }
    
    
    // MARK: Private Methods
    @objc
    private func _dismiss() {
        dismiss(animated: true)
    }
    
    

}
extension UISegmentedControl {
    /// Tint color doesn't have any effect on iOS 13.
    func iOSStyle() {
        if #available(iOS 13, *) {
            let tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            let backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 221/255, alpha: 1)
            let tintColorImage = UIImage(color: tintColor)
            
            // Must set the background image for normal to something (even clear) else the rest won't work
            setBackgroundImage(UIImage(color: backgroundColor ), for: .normal, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            setBackgroundImage(UIImage(color: tintColor.withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            setTitleTextAttributes([.foregroundColor: tintColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)], for: .normal)
            setTitleTextAttributes([.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .bold)], for: .selected)
//            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//            layer.borderWidth = 1
//            layer.borderColor = tintColor.cgColor
        }
    }
}
public extension UIImage {
  public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
