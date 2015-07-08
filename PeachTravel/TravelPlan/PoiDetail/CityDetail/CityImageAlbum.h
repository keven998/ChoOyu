//
//  CityAlbumView.h
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CityAlbumViewDelegate <NSObject>

@optional
- (void)viewImage:(NSInteger)index;

@end

@interface CityImageAlbum : UIView

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, weak) id <CityAlbumViewDelegate> delegate;

+ (CGFloat)heightOfCityAlbumViewWithWidth:(CGFloat)width;

@end
