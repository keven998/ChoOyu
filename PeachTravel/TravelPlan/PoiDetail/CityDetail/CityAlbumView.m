//
//  CityAlbumView.m
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "CityAlbumView.h"

@interface CityAlbumView ()

@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeCostLabel;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageBtns;

@end

@implementation CityAlbumView

- (IBAction)viewImage:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate viewImage:sender.tag];
    }
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    for (int i = 0; i < self.imageBtns.count; i++) {
        UIButton *btn = self.imageBtns[i];
        if (_images.count >= i+1) {
            TaoziImage *image= _images[i];
            [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:image.imageUrl] forState:UIControlStateNormal];
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
