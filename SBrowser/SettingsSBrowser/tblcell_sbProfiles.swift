//
//  tblcell_sbProfiles.swift
//  SBrowser
//
//  Created by Jin Xu on 24/02/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class tblcell_sbProfiles: UITableViewCell {

    @IBOutlet weak var lblexpiredate: UILabel!
    @IBOutlet weak var lblissuedby: UILabel!
    @IBOutlet weak var lbltitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
