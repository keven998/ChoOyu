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
    
    cell.textLabel.text = self.siteArray[indexPath.row];
    [cell.textLabel setTextColor:TZColor(100, 100, 100)];
    cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:16];
    
    if (self.showAccessory == indexPath.row) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArtboardCheck@3x"]];
    }
    
    
    return cell;
}

#pragma mark - 设置tableView的代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    
    if (self.tag == 1) {
        [self.delegateDrop didSelectedcityIndex:indexPath.row categaryIndex:1 andTag:1];
    }else{
        [self.delegateDrop didSelectedcityIndex:1 categaryIndex:indexPath.row andTag:2];
    }
}

@end