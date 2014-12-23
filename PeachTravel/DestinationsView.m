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
        self.backgroundColor = [UIColor whiteColor];
        _destinationToolBar = [[DestinationToolBar alloc] initWithFrame:CGRectMake(offsetX, 0, frame.size.width-offsetX, frame.size.height)];
        _destinationToolBar.backgroundColor = [UIColor whiteColor];
        [self addSubview:_destinationToolBar];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 45)];
        titleLabel.textColor = TEXT_COLOR_TITLE;
        titleLabel.text = @"目的地 :";
        titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
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
        DestinationUnit *unit = [_destinationToolBar addUnit:nil withName:title andUnitHeight:25 userInteractionEnabled:NO];
        unit.tag = i;
        [unit setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        unit.layer.borderColor = TEXT_COLOR_TITLE_SUBTITLE.CGColor;
        unit.layer.cornerRadius = 2.0;
        unit.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [destinationItemsArray addObject:unit];
    }
    
   [_destinationToolBar.scrollView setContentOffset:CGPointZero];
    _destinationItmes = destinationItemsArray;
}

@end



