//
//  GoodsRecommendHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoSlideScrollView.h"

@protocol GoodsRecommendHeaderViewDelegate <NSObject>

- (void)didSelectItem:(NSString *)itemUri;

@end

@interface GoodsRecommendHeaderView : UIView

@property (nonatomic, strong) NSArray *recommendData;
@property (nonatomic, weak) id <GoodsRecommendHeaderViewDelegate> delegate;
@property (strong, nonatomic) AutoSlideScrollView *galleryView;

@end
