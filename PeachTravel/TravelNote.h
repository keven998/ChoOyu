//
//  TravelNote.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TravelNote : NSObject

@property (nonatomic, copy) NSString *travelNoteId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorAvatar;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *sourceUrl;
@property (nonatomic, copy) NSString *publishDateStr;

- (id)initWithJson:(id)json;
@end
