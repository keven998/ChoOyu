//
//  GoodsRecommendHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendHeaderView.h"
#import "AutoSlideScrollView.h"

@interface GoodsRecommendHeaderView()

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet AutoSlideScrollView *galleryView;

@end


@implementation GoodsRecommendHeaderView

+ (id)initViewFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"GoodsRecommendHeaderView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.galleryView.backgroundColor = [UIColor redColor];  
    self.galleryView.totalPagesCount = ^NSInteger() {
        return 10;
    };
    [_searchBtn setBackgroundImage:[[UIImage imageNamed:@"icon_goods_search_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 40, 5, 20)] forState:UIControlStateNormal];
}

@end
