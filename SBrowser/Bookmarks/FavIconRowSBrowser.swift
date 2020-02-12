//
//  FavIconRowSBrowser.swift
//  SBrowser
//
//  Created by Jin Xu on 24/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

public final class FavIconCellSBrowser: PushSelectorCell<UIImage> {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var editableIndicator: UIImageView!
    
    public override func update() {
        super.update()
        
        accessoryType = .none
        editingAccessoryView = .none
        
        icon.image = row.value ?? (row as? ImageRowProtocol)?.placeholderImage
        editableIndicator.isHidden = row.isDisabled
    }
}

final class FavIconRowSBrowser: _ImageRow<FavIconCellSBrowser>, RowType {

    required init(tag: String?) {
        super.init(tag: tag)

        cellProvider = CellProvider<FavIconCellSBrowser>(nibName: String(describing: FavIconCellSBrowser.self))
    }
}
