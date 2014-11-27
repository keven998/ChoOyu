//
//  DestinationsView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "DestinationsView.h"
#import "DestinationToolBar.h"

@interface DestinationsView ()

@property (nonatomic, strong) DestinationToolBar *destinationToolBar;

@end

@implementation DestinationsView

- (instancetype)initWithFrame:(CGRect)frame andContentOffsetX:(CGFloat)offsetX
{
    self = [super initWithFrame:frame];
    if (self) {
        _destinationToolBar = [[DestinationToolBar alloc] initWithFrame:CGRectMake(offsetX, 20, frame.size.width-offsetX, frame.size.height-20)];
        [self addSubview:_destinationToolBar];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 0, frame.size.width-offsetX, 20)];
        titleLabel.text = @"我的目的地";
        [self addSubview:titleLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andContentOffsetX:0];
}


- (void)setDestinations:(NSArray *)destinations
{
    NSMutableArray *destinationItemsArray = [[NSMutableArray alloc] init];
    _destinations = destinations;
    for (int i = 0; i < _destinations.count; i++) {
        NSString *title = [_destinations objectAtIndex:i];
        DestinationUnit *unit = [_destinationToolBar addUnit:nil withName:title];
        unit.tag = i;
        [destinationItemsArray addObject:unit];
    }
    
   [_destinationToolBar.scrollView setContentOffset:CGPointZero];
    _destinationItmes = destinationItemsArray;
}

@end



