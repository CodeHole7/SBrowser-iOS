//
//  UIColor+Helper.swift
//  SBrowser
//
//  Created by Jin Xu on 25/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

public extension UIColor {

    /**
     Background, dark purple, code #3F2B4F
     */
    @objc
    static var accent = UIColor(named: "Accent")

    /**
     Intro progress bar background, darker purple, code #352144
     */
    @objc
    static var accentDark = UIColor(named: "AccentDark")

    /**
     Background for connecting view, light Tor purple, code #A577BB
     */
    @objc
    static var accentLight = UIColor(named: "AccentLight")

    /**
     Red error view background, code #FB5427
     */
    @objc
    static var error = UIColor.init(named: "Error")

    /**
     Green connected indicator line, code #7ED321
     */
    @objc
    static var ok = UIColor(named: "Ok")
    
    
    @objc
    static var bgColor = UIColor(named: "bgColor")
}
