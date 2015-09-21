//
//  SearchDestinationRecommendViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchDestinationRecommendDelegate <NSObject>

- (void)didSelectItemWithSearchText:(NSString *)searchText;

@end

@interface SearchDestinationRecommendViewController : UIViewController

@property (nonatomic, weak) id<SearchDestinationRecommendDelegate> delegate;

@property (nonatomic) TZPoiType poiType;

- (void)addSearchHistoryText:(NSString *)searchText;

@end
