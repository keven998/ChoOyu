//
//  TZTagsCollectionView.swift
//  PeachTravel
//
//  Created by liangpengshuai on 10/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class TZTagsCollectionView: UICollectionView, TaoziLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var tagsList: Array<String>! {
        didSet {
            self.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.whiteColor()
        tagsList = Array()
        if self.collectionViewLayout is TaoziCollectionLayout {
            let tzLayout: TaoziCollectionLayout = self.collectionViewLayout as! TaoziCollectionLayout
            tzLayout.delegate = self
        }
        self.delegate = self;
        self.dataSource = self;
        self.registerNib(UINib(nibName: "TZTagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tzTagCollectionCell")
    }
    
//    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
//        tagsList = Array()
//        super.init(frame: frame, collectionViewLayout: layout)
//        if layout is TaoziCollectionLayout {
//            let tzLayout: TaoziCollectionLayout = layout as! TaoziCollectionLayout
//            tzLayout.delegate = self
//        }
//        self.delegate = self;
//        self.dataSource = self;
//        self.registerNib(UINib(nibName: "TZTagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tzTagCollectionCell")
//    }
    
    //MARK: UICollectionViewDataSource
    
    override func numberOfItemsInSection(section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: TZTagCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("tzTagCollectionCell", forIndexPath: indexPath) as! TZTagCollectionViewCell
        cell.titleBackgroundColor = APP_THEME_COLOR
        cell.title = tagsList[indexPath.row]
        return cell
    }
    
    //MARK: TaoziLayoutDelegate
    func tzCollectionLayoutWidth() -> CGFloat {
        return self.bounds.size.width
    }
    
    func tzCollectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return tagsList.count
    }
    
    func tzCollectionView(collectionView: UICollectionView!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(40, 15)
    }
    
    func tzNumberOfSectionsInTZCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }

    func tzCollectionview(collectionView: UICollectionView!, sizeForHeaderView indexPath: NSIndexPath!) -> CGSize {
        return CGSizeZero
    }
}
