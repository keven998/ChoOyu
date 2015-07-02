//
//  CityAlbumView.m
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "CityImageAlbum.h"

@interface CityImageAlbum ()

@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeCostLabel;
@property (weak, nonatomic) IBOutlet UIButton *backgroundCard;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageContents;

@end

@implementation CityImageAlbum

- (void)awakeFromNib {
    [_backgroundCard setBackgroundImage:[[UIImage imageNamed:@"city_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_backgroundCard setBackgroundImage:[[UIImage imageNamed:@"city_bg_album_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [_backgroundCard addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
}
 
- (void)setImages:(NSArray *)images
{
    _images = images;
    NSInteger linkCount = self.imageContents.count;
    NSInteger viewCount = images.count;
    for (int i = 0; i < linkCount && i < viewCount; i++) {
        UIImageView *imageView = self.imageContents[i];
        TaoziImage *image= _images[i];
        imageView.layer.cornerRadius = 5.0;
        [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:[UIImage imageNamed:@"city_bg_photo_default.png"]];
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _TitleLabel.text = _title;
}

- (void)setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    _timeCostLabel.text = _subTitle;
}

- (void)viewImage:(NSInteger)index
{
    if (self.delegate) {
        [self.delegate viewImage:index];
    }
}

+ (CGFloat)heightOfCityAlbumViewWithWidth:(CGFloat)width
{
    CGFloat titleHeight = 60;
    CGFloat leftMargin = 25;
    CGFloat topMargin = 22;

    CGFloat space = 15;
    CGFloat heightPerBtn = (width-leftMargin*2-space*2)/3;
    return titleHeight + topMargin*2 + heightPerBtn*2;
    
}

@end
