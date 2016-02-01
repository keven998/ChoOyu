//
//  UploadPhotoOperationView.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UploadPhotoOperationView.h"

@interface UploadPhotoOperationView() <UITextViewDelegate>

@property (nonatomic, strong) UILabel *placeHolder;

@end

@implementation UploadPhotoOperationView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    
    _textView.layer.borderWidth = 0.5;
    _textView.layer.borderColor = COLOR_LINE.CGColor;
    
    _textView.textColor = COLOR_TEXT_II;
    _textView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(50, 50);
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    
    _placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, 40)];
    _placeHolder.textColor = COLOR_TEXT_II;
    _placeHolder.font = [UIFont systemFontOfSize:16.0];
    _placeHolder.text = @"输入点评...";
    [_textView addSubview:_placeHolder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

+ (id)uploadUserPhotoView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"UploadPhotoOperationView" owner:nil options:nil] lastObject];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
@end
