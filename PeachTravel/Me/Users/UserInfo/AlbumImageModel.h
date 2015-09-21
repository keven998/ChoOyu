//
//  AlbumImageModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumImageModel : NSObject

@property (nonatomic, copy) NSString *imageId;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *smallImageUrl;
@property (nonatomic, copy) NSString *imageDesc;
@property (nonatomic) long createTime;

- (id)initWithJson:(id)json;

@end
