//
//  CustomMKAnnotationView.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/25/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CustomMKAnnotationView.h"

@interface CustomMKAnnotationView()

//@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CustomMKAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.45, 0.9);
        NSLog(@"self.layer.anchorPoint %@", NSStringFromCGPoint(self.layer.anchorPoint));
    }
    
    return self;
}

- (void)setPinImageName:(NSString *)pinImageName
{
    _pinImageName = pinImageName;
    self.image = [UIImage imageNamed:_pinImageName];
}

@end
