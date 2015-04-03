//
//  UISelectionViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/3.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "UISelectionViewController.h"

@interface UISelectionViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation UISelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blueColor];
    
    self.navigationItem.title = _titleTxt;
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = lbtn;
    
    _tableview.backgroundColor = [UIColor redColor];
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"select_cell"];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    NSLog(@"count = %lu", (unsigned long)_contentItems.count);
}

#pragma mark - IBAction
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"select_cell" forIndexPath:indexPath];
    cell.textLabel.text = [_contentItems objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self goBack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
