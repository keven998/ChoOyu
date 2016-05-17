//
//  MakeOrderSelectCountTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MakeOrderSelectCountDelegate <NSObject>

@optional
- (void)updateSelectCount:(NSInteger)count;

@end

@interface MakeOrderSelectCountTableViewCell : UITableViewCell

@property (nonatomic) NSUInteger count;
@property (nonatomic, weak) id<MakeOrderSelectCountDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
