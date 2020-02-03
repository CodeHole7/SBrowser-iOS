//
//  BookmarkCellSBrowser.swift
//  SBrowser
//
//  Created by JinXu on 23/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class BookmarkCellSBrowser: UITableViewCell {

    class var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    class var reuseId: String {
        return String(describing: self)
    }

    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var nameLeading: NSLayoutConstraint!


    func set(_ bookmark: BookmarkSBrowser) -> BookmarkCellSBrowser {
        iconImg.image = bookmark.icon

        if iconImg.image == nil {
            iconWidth.constant = 0
            nameLeading.constant = 0
        }
        else {
            iconWidth.constant = 32
            nameLeading.constant = 8
        }

        nameLb.text = bookmark.name?.isEmpty ?? true
            ? bookmark.url?.absoluteString
            : bookmark.name

        return self
    }
    
}
