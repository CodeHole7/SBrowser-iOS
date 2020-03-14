//
//  OtherClasses.swift
//  SBrowser
//
//  Created by Jin Xu on 25/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation
import Eureka

class SBFixedFormVC: FormViewController {

    override func keyboardWillShow(_ notification: Notification) {
        // When showing inside a popover on iPad, the popover gets resized on
        // keyboard display, so we shall not do this inside the view.
        if popoverPresentationController != nil && UIDevice.current.userInterfaceIdiom == .pad {
            return
        }

        super.keyboardWillShow(notification)
    }
}

class TemporarilyAllowedURLSwift: NSObject {
    var url: URL?
    var wvt: TabSBrowser?
    var ocspRequest: Bool?
    init(url: URL, wvt: TabSBrowser, isOCSPRequest: Bool) {
        self.url = url
        self.wvt = wvt
        self.ocspRequest = isOCSPRequest
    }
}
