//
//  PicCell.m
//  
//
//  Created by dapiao on 15/5/3.
//
//

#import "PicCell.h"

@implementation PicCell

- (void)awakeFromNib {
    // Initialization code
    _picImage.layer.cornerRadius = 2;
    _picImage.clipsToBounds = YES;
}

@end
