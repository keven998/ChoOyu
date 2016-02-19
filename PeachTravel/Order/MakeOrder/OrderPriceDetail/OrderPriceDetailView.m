//
//  OrderPriceDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderPriceDetailView.h"
#import "OrderPriceDetailTableViewCell.h"

@interface OrderPriceDetailView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) CGFloat titleHeight;
@property (nonatomic) CGFloat itemHeight;

@end

@implementation OrderPriceDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemHeight = 45;
        _titleHeight = 50;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self addSubview:self.tableView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePriceDetailView)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        self.clipsToBounds = YES;
      
    }
    return self;
}

- (void)showPriceDetailView
{
    [self showPriceDetailViewWithAnimated:YES];
}

- (void)showPriceDetailViewWithAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
            NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
            
            NSLog(@"%@", NSStringFromCGRect(self.frame));

            self.tableView.frame = CGRectMake(0, self.bounds.size.height-self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        self.alpha = 1;
        self.tableView.frame = CGRectMake(0, self.bounds.size.height-self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
    }
}

- (void)hidePriceDetailView
{
    [self hidePriceDetailViewWithAnimated:YES];
}

- (void)hidePriceDetailViewWithAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
            self.tableView.frame = CGRectMake(0, self.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
            
        } completion:^(BOOL finished) {
            [_tableView removeFromSuperview];
            _tableView = nil;
            [self removeFromSuperview];
        }];
        
    } else {
        [_tableView removeFromSuperview];
        _tableView = nil;
        [self removeFromSuperview];
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat height = _titleHeight + _itemHeight*2;
        if (height > self.bounds.size.height/2) {
            height = self.bounds.size.height/2;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-height, self.bounds.size.width, height)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = COLOR_LINE;
        _tableView.scrollEnabled = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"OrderPriceDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderPriceDetailTableViewCell"];
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, _titleHeight)];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableHeaderView.bounds.size.width-24, _titleHeight)];
        headerLabel.text = @"费用明细";
        headerLabel.textColor = COLOR_TEXT_I;
        headerLabel.font = [UIFont systemFontOfSize:16.0];
        [tableHeaderView addSubview:headerLabel];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, _titleHeight-0.5, tableHeaderView.bounds.size.width, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [tableHeaderView addSubview:spaceView];
        
        _tableView.tableHeaderView = tableHeaderView;
    }
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderPriceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderPriceDetailTableViewCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.contentLabel.text = _orderDetail.selectedPackage.packageName;
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%@*%ld", _orderDetail.formatUnitPrice, _orderDetail.count];
    } else {
        cell.contentLabel.text = @"优惠";
        cell.priceLabel.text = [NSString stringWithFormat:@"-￥%@", _orderDetail.formatDiscountPrice];
    }
    return cell;
}

@end




