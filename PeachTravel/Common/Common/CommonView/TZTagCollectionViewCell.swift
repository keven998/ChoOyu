//
//  TZTagCollectionViewCell.swift
//  PeachTravel
//
//  Created by liangpengshuai on 10/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class TZTagCollectionViewCell: UICollectionViewCell {
    
    var titleBackgroundColor: UIColor? {
        didSet {
            self.titleLabel.backgroundColor = titleBackgroundColor
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = COLOR_TEXT_III
        titleLabel.layer.cornerRadius = 5.0
        titleLabel.clipsToBounds = true
    }

}
