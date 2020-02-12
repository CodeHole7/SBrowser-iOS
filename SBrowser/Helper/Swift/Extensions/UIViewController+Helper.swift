//
//  UIViewController+Helper.swift
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

extension UIViewController {
    
    /**
    Presents a view controller modally animated.

    Does it as a popover, when a `sender` object is provided.

    - parameter vc: The view controller to present.
    - parameter sender: The `UIView` with which the user triggered this operation.
    */
    func present(_ vc: UIViewController, _ sender: UIView? = nil) {
        if let sender = sender {
            vc.modalPresentationStyle = .popover//.fullScreen//.popover
            vc.popoverPresentationController?.sourceView = sender.superview
            vc.popoverPresentationController?.sourceRect = sender.frame

            if let delegate = vc as? UIPopoverPresentationControllerDelegate {
                vc.popoverPresentationController?.delegate = delegate
            }
        }

        present(vc, animated: true)
    }
}
