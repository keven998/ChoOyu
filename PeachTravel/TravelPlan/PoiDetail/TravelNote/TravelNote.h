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
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorAvatar;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *detailUrl;
@property (nonatomic, copy) NSString *publishDateStr;

- (id)initWithJson:(id)json;

- (void)asyncFavorite:(NSString *)poiId poiType:(NSString *)type isFavorite:(BOOL)isFavorite completion:(void (^) (BOOL isSuccess))completion;

@end
