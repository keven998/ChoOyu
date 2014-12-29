//
//  PushSettingViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "PushSettingViewController.h"
#import "PushSettingTableViewCell.h"

@interface PushSettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation PushSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PushSettingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"push_cell"];
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PushSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"push_cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.titleView.text = @"贴心旅行相关推送";
        [cell.switchButton addTarget:self action:@selector(enablePush:) forControlEvents:UIControlEventValueChanged];
    } else if (indexPath.row == 1) {
        cell.titleView.text = @"桃·Talk提醒";
        [cell.switchButton addTarget:self action:@selector(enableCircleMsg:) forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}

#pragma IBAction
-(void)enablePush:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL on = [switchButton isOn];
    if (on) { //TODO
        
    } else {
        
    }
}

-(void)enableCircleMsg:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL on = [switchButton isOn];
    if (on) { //TODO
        
    } else {
    
    }
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
    } else {
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
