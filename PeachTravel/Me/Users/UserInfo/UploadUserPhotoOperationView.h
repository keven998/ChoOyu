//
//  UploadUserPhotoOperationView.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadUserPhotoOperationView : UIView 

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

+ (id)uploadUserPhotoView;

+ (CGFloat)heigthWithPhotoCount:(NSUInteger)count;

@end
