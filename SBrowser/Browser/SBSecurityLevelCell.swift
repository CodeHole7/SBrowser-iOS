//
//  SBSecurityLevelCell.swift
//  SBrowser
//
//  Created by Jin Xu on 25/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

class SBSecurityLevelCell: UITableViewCell {

    class var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    class var reuseId: String {
        return String(describing: self)
    }

    class var height: CGFloat {
        return 64
    }

    static var shieldImage = UIImage(named: "Shield")
    static var customShieldImage = UIImage(named: "custom-shield")


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var shieldImg: UIImageView!
    @IBOutlet weak var numberLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var explanationLb: UILabel!
    @IBOutlet weak var radioLb: UILabel! {
        didSet {
            radioLb.layer.borderColor = UIColor.accent?.cgColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            radioLb.backgroundColor = .ok
            radioLb.text = "\u{2713}" // Checkmark
        }
        else {
            radioLb.backgroundColor = .clear
            radioLb.text = nil
        }
    }

    @discardableResult
    func set(_ preset: SecurityPreset) -> SBSecurityLevelCell {

        if preset == .custom {
            shieldImg.image = SBSecurityLevelCell.customShieldImage
            numberLb.isHidden = true
        }
        else {
            shieldImg.image = SBSecurityLevelCell.shieldImage
            numberLb.isHidden = false
            numberLb.text = preset.shortcode
        }

        let text = NSMutableAttributedString(string: preset.description)

        if let recommendation = preset.recommendation {
            let size = nameLb.font.pointSize - 2
            var font = UIFont.systemFont(ofSize: size, weight: .bold)

            if let descriptor = font.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
                font = UIFont(descriptor: descriptor, size: size)
            }

            text.append(NSAttributedString(string: " "))
            text.append(NSAttributedString(string: recommendation, attributes: [
                .font: font,
            ]))
        }

        nameLb.attributedText = text

        explanationLb.text = preset.explanation

        return self
    }
}
