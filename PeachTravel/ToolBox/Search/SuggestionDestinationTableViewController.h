//
//  SuggestionDestinationTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SuggestionDestinationTableViewControllerDelegate <NSObject>

- (void)didSelectDestination:(CityDestinationPoi *)poi;

@end

@interface SuggestionDestinationTableViewController : UITableViewController

@property (nonatomic, weak) id <SuggestionDestinationTableViewControllerDelegate>delegate;

@end
