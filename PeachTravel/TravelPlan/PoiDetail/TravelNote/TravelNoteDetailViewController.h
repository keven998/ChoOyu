//
//  TravelNoteDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoiDetailSuperViewController.h"
#import "TravelNote.h"

@interface TravelNoteDetailViewController : UIViewController

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, strong) TravelNote *travelNote;

@end
