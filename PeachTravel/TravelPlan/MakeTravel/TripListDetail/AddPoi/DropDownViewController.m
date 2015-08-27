//
//  DropDownViewController.m
//  PeachTravel
//
//  Created by 王聪 on 15/7/18.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DropDownViewController.h"
@interface DropDownViewController ()

@end

@implementation DropDownViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置tableView不能滚动
//    self.tableView.scrollEnabled = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)setSiteArray:(NSArray *)siteArray
{
    _siteArray = siteArray;
    
    // 将数组传递进来后刷新表格
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.siteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 添加分割线
    if (indexPath.row != self.siteArray.count - 1) {
        UIView * underLine = [[UIView alloc] init];
        underLine.backgroundColor = [UIColor grayColor];
        underLine.alpha = 0.5;
        underLine.frame = CGRectMake(0, cell.frame.size.height - 1, kWindowWidth, 1);
        [cell addSubview:underLine];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = self.siteArray[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
//    cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.showAccessory == indexPath.row) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point"]];
        [cell.textLabel setTextColor:APP_THEME_COLOR];
//        cell.backgroundColor = [UIColor grayColor];
    }
    
    
    return cell;
}

#pragma mark - 设置tableView的代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    
    if (self.tag == 1) {
        [self.delegateDrop didSelectedcityIndex:indexPath.row categaryIndex:1 andTag:1];
    } else if (self.tag == 2) {
        [self.delegateDrop didSelectedcityIndex:1 categaryIndex:indexPath.row andTag:2];
    } else {
        [self.delegateDrop didSelectedContinentIndex:indexPath.row];
    }
}

@end
