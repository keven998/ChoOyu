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

}
 
- (void)setImages:(NSArray *)images
{
    _images = images;
    for (int i = 0; i < self.imageContents.count; i++) {
        UIImageView *imageView = self.imageContents[i];
        if (_images.count >= i+1) {
            TaoziImage *image= _images[i];
            imageView.layer.cornerRadius = 7.0;
            imageView.clipsToBounds = YES;
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        } else {
            break;
        }
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
