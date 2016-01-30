//
//  GoodsDetailHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailHeaderView.h"
#import "AutoSlideScrollView.h"
#import "EDStarRating.h"

@interface GoodsDetailHeaderView ()

@property (strong, nonatomic) AutoSlideScrollView *galleryView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *saleCountLabel;
@property (strong, nonatomic) EDStarRating *ratingView;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *pageIndexLabel;

@end

@implementation GoodsDetailHeaderView

+ (CGFloat)heightWithGoodsmodel:(GoodsDetailModel *)goodsModel
{
    CGFloat retHeight = kWindowWidth/2;  //图片高度
    
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    NSString *title = [NSString stringWithFormat:@"[%@]  %@", [goodsModel.category firstObject], goodsModel.goodsName];
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:title attributes:attribs];
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    retHeight += rect.size.height+20;   //商品 titile
    
    retHeight += 30;    //价格

    return retHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self renderContentView];
    }
    return self;
}

- (void)renderContentView
{
    self.backgroundColor = [UIColor whiteColor];
     _galleryView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width/2)];
    _galleryView.shouldHidePageControl = YES;
    _galleryView.scrollView.showsHorizontalScrollIndicator = NO;
    __weak GoodsDetailHeaderView *weakSelf = self;
    _galleryView.didChange2Page = ^(NSInteger pageIndex) {
        if (pageIndex >= 0 && pageIndex < weakSelf.goodsDetail.images.count) {
            weakSelf.pageIndexLabel.text = [NSString stringWithFormat:@"%ld/%ld", pageIndex+1, weakSelf.goodsDetail.images.count];
        }

    };
    [self addSubview:_galleryView];
    
    _pageIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(_galleryView.bounds.size.width-60, _galleryView.bounds.size.height-35, 50, 25)];
    _pageIndexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _pageIndexLabel.textColor = [UIColor whiteColor];
    _pageIndexLabel.font = [UIFont systemFontOfSize:15];
    _pageIndexLabel.textAlignment = NSTextAlignmentCenter;
    _pageIndexLabel.layer.cornerRadius = 6.0;
    _pageIndexLabel.clipsToBounds = YES;
    [_galleryView addSubview:_pageIndexLabel];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = COLOR_TEXT_I;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_titleLabel];
    
    _saleCountLabel = [[UILabel alloc] init];
    _saleCountLabel.textColor = COLOR_TEXT_II;
    _saleCountLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:_saleCountLabel];
    
    _ratingView = [[EDStarRating alloc] init];
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 1;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
    [self addSubview:_ratingView];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_priceLabel];

}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    _pageIndexLabel.text = [NSString stringWithFormat:@"1/%ld", _goodsDetail.images.count];
    __weak GoodsDetailHeaderView *weakSelf = self;
    self.galleryView.totalPagesCount = ^NSInteger() {
        return weakSelf.goodsDetail.images.count;
    };
    self.galleryView.fetchContentViewAtIndex = ^UIView*(NSInteger pageIndex) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.frame.size.width, weakSelf.frame.size.width/2)];
        TaoziImage *image = [goodsDetail.images objectAtIndex:pageIndex];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        return imageView;
    };
    
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    NSString *category = [NSString stringWithFormat:@"[%@]", [_goodsDetail.category firstObject]];
    NSString *title = [NSString stringWithFormat:@"%@  %@", category, _goodsDetail.goodsName];
    NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:title attributes:attribs];
    [attrstr addAttributes:@{NSForegroundColorAttributeName: APP_THEME_COLOR,
                             NSFontAttributeName: [UIFont boldSystemFontOfSize:14]
                             } range:NSMakeRange(0, category.length)];
    
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _titleLabel.frame = CGRectMake(12, CGRectGetMaxY(_galleryView.frame)+10, self.frame.size.width-24, rect.size.height+2);
    _titleLabel.attributedText = attrstr;
    
    _ratingView.frame = CGRectMake(12, CGRectGetMaxY(_titleLabel.frame)+9, 60, 20);
    [_ratingView setRating:_goodsDetail.rating*5];
    
    _saleCountLabel.text = [[NSString alloc] initWithFormat:@"%ld已售", _goodsDetail.saleCount];
    _saleCountLabel.frame = CGRectMake(CGRectGetMaxX(_ratingView.frame)+5, CGRectGetMaxY(_titleLabel.frame)+10, 60, 20);
    
    NSString *price = [NSString stringWithFormat:@"￥%@ ￥%@起", _goodsDetail.formatPrimePrice, _goodsDetail.formatCurrentPrice];
    _priceLabel.frame =  CGRectMake(CGRectGetMaxX(_saleCountLabel.frame)+10, CGRectGetMaxY(_titleLabel.frame)+10, self.bounds.size.width-10-12-CGRectGetMaxX(_saleCountLabel.frame), 20);
    
    NSMutableAttributedString *priceAttr = [[NSMutableAttributedString alloc] initWithString:price];
    [priceAttr addAttributes:@{NSForegroundColorAttributeName: COLOR_TEXT_III,
                             NSFontAttributeName: [UIFont systemFontOfSize:13],
                               NSStrikethroughStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                             } range:NSMakeRange(0, _goodsDetail.formatPrimePrice.length+1)];
    
    [priceAttr addAttributes:@{NSForegroundColorAttributeName:COLOR_PRICE_RED,
                             NSFontAttributeName: [UIFont systemFontOfSize:17]
                             } range:NSMakeRange( _goodsDetail.formatPrimePrice.length+2, _goodsDetail.formatCurrentPrice.length+1)];
    
    [priceAttr addAttributes:@{NSForegroundColorAttributeName:COLOR_PRICE_RED,
                               NSFontAttributeName: [UIFont systemFontOfSize:13]
                               } range:NSMakeRange( price.length-1, 1)];
    _priceLabel.attributedText = priceAttr;
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [self addSubview:spaceView];


}
@end
