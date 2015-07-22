//
//  JobListViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/4/29.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "JobListViewController.h"

@interface JobListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    
}
@end

@implementation JobListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _dataArray = [NSArray array];
    
    [self createTableView];
}
-(void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = _dataArray[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *job;
    job = _dataArray[indexPath.row];
    [self.delegate changeJob:job];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
