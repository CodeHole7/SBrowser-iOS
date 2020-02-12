//
//  UISearchBar+Helper.swift
//  SBrowser
//
//  Created by Jin Xu on 22/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension UISearchBar {

    /// Returns the`UITextField` that is placed inside the text field.
    var textField: UITextField {
        if #available(iOS 13, *) {
            return searchTextField
        } else {
            return self.value(forKey: "_searchField") as! UITextField
        }
    }

}
