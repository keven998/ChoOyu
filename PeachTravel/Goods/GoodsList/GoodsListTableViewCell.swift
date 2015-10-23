//
//  GoodsListTableViewCell.swift
//  PeachTravel
//
//  Created by liangpengshuai on 10/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class GoodsListTableViewCell: UITableViewCell {
    
    var goodModel: SuperGoodsModel? {
        didSet {
            self.updateView()
        }
    }

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tagsCollectionView: TZTagsCollectionView!
    @IBOutlet weak var propertyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = COLOR_TEXT_I;
        subtitleLabel.textColor = COLOR_TEXT_II;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateView() {
        titleLabel.text = goodModel?.zhName
        subtitleLabel.text = goodModel?.desc
        tagsCollectionView.tagsList = self.goodModel?.tags
        if let image = goodModel?.images?.first {
            headerImageView.sd_setImageWithURL(NSURL(string: image.imageUrl))
        }
        let rate = Int((goodModel?.rating)!*100)
        propertyButton.setImage(UIImage(named: "goodsRating.png"), forState: UIControlState.Normal)
        let propertyStr = "\(rate)%满意  |   销量：\(goodModel?.sales)"
        propertyButton.setTitle(propertyStr, forState: UIControlState.Normal)
    }
}
