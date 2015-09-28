//
//  UploadUserPhotoOperationView.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UploadUserPhotoOperationView.h"

@interface UploadUserPhotoOperationView() <UITextViewDelegate>

@property (nonatomic, strong) UILabel *placeHolder;

@end

@implementation UploadUserPhotoOperationView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    _textView.textColor = COLOR_TEXT_II;
    _textView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.scrollEnabled = NO;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGFloat itemWidth = (kWindowWidth-10*2-8*3)/4;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 49, 10);
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    
    _placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, 40)];
    _placeHolder.textColor = COLOR_TEXT_II;
    _placeHolder.font = [UIFont systemFontOfSize:16.0];
    _placeHolder.text = @"给照片写点什么把...";
    [_textView addSubview:_placeHolder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

+ (id)uploadUserPhotoView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"UploadUserPhotoOperationView" owner:nil options:nil] lastObject];
}

+ (CGFloat)heigthWithPhotoCount:(NSUInteger)count
{
    CGFloat retHeight = 0.0;
    retHeight += 100;
    
    NSUInteger line = ceilf(count/4.0);
    CGFloat itemWidth = (kWindowWidth-20 - 3*8)/4;
    retHeight += (20 + (line-1)*8 + itemWidth * line);
    return retHeight;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _placeHolder.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _placeHolder.hidden = (textView.text.length != 0);
}

@end
