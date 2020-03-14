//
//  SBBlurredSnapshot.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBBlurredSnapshot: NSObject {
    
    private static var view: UIView?

    /**
    Blur current window content to increase privacy when in background.

    Call this from AppDelegate#applicationWillResignActive:
    */
    @objc class func create() {
        // Blur current content to increase privacy when in background.
        if view == nil,
            let delegate = AppDelegate.shared {

            view = delegate.window?.snapshotView(afterScreenUpdates: false)

            let vev = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            vev.frame = view!.bounds

            view?.addSubview(vev)
            delegate.window?.addSubview(view!)
        }
    }

    /**
    Remove blurred snapshot again when coming back from background.

    Call this from AppDelegate#applicationDidBecomeActive:
    */
    @objc class func remove() {
        view?.removeFromSuperview()
        view = nil
    }
    
}
