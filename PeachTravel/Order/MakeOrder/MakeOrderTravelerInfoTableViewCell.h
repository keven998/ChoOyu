//
//  MakeOrderTravelerInfoTableViewCell.h
//  
//
//  Created by liangpengshuai on 11/9/15.
//
//

#import <UIKit/UIKit.h>

@protocol MakeOrderEditTravelerInfoDelegate <NSObject>

- (void)finishEditTravelerWithTravelerList:(NSArray *) travelerList;

@end

@interface MakeOrderTravelerInfoTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *travelerList;
@property (weak, nonatomic) IBOutlet UIButton *editTravelerButton;

@property (nonatomic, weak) id<MakeOrderEditTravelerInfoDelegate> delegate;

+ (CGFloat)heightWithTravelerCount:(NSInteger)count;

@end
