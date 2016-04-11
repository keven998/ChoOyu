//
//  PTMakeSelectContentTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTMakeSelectContentTableViewControllerDelegate <NSObject>

- (void)didSelectServiceContent:(NSArray *)contentList;

- (void)didSelectTopicContent:(NSArray *)contentList;

@end

@interface PTMakeSelectContentTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, weak) id <PTMakeSelectContentTableViewControllerDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *selectContentList;
@property (nonatomic) BOOL isSelectTopic;

@end
