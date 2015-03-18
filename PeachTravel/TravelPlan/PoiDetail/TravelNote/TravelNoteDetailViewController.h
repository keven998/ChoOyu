//
//  TravelNoteDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SuperWebViewController.h"
#import "PoiDetailSuperViewController.h"
#import "TravelNote.h"

@interface TravelNoteDetailViewController : UIViewController

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, strong) TravelNote *travelNote;

//@property (nonatomic, copy) NSString *travelNoteTitle;
//@property (nonatomic, copy) NSString *desc;
//@property (nonatomic, copy) NSString *travelNoteId;
//@property (nonatomic, copy) NSString *travelNoteCover;
//@property (nonatomic, copy) NSString *urlStr;

@end
