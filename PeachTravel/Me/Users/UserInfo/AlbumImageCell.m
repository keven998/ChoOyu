//
//  AlbumImageCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/2/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "AlbumImageCell.h"

@implementation AlbumImageCell

- (void)awakeFromNib {
    
    _editBtn.backgroundColor = [UIColor redColor];
//    [_editBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    CGFloat t =2.0;
    
    CGAffineTransform leftQuake  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,-t);
    CGAffineTransform rightQuake =CGAffineTransformTranslate(CGAffineTransformIdentity,-t, t);
    
    _editBtn.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(_editBtn)];
    [UIView setAnimationRepeatAutoreverses:YES];// important
    [UIView setAnimationRepeatCount:1000000];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    _editBtn.transform = rightQuake;// end here & auto-reverse
    
    [UIView commitAnimations];
    _editBtn.hidden = YES;
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)earthquakeEnded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    
    if([finished boolValue])
    {
        UIView* item =(__bridge UIView*)context;
        item.transform =CGAffineTransformIdentity;
    }
    
}
@end
