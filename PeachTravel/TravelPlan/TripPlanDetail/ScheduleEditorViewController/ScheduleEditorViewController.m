//
//  ScheduleEditorViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ScheduleEditorViewController.h"
#import "PoiOnEditorTableViewCell.h"

@interface ScheduleEditorViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_cityArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ScheduleEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"修改行程";
    UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(onScheduleChanged:)];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = finishBtn;
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    _cityArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PoiOnEditorTableViewCell" bundle:nil] forCellReuseIdentifier:@"poi_cell_of_edit"];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tripDetail.itineraryList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_tripDetail.itineraryList objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = tableView.frame.size.width;
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(37, 25, width-80, 24)];
    headerTitle.textColor = COLOR_TEXT_I;
    headerTitle.font = [UIFont systemFontOfSize:15.0];
    headerTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString *titleStr = [NSString stringWithFormat:@"DAY%ld ",(long)section+1];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (SuperPoi *tripPoi in [_tripDetail.itineraryList objectAtIndex:section]) {
        if (tripPoi.locality.zhName) {
            [set addObject:tripPoi.locality.zhName];
            [_cityArray addObject:tripPoi.locality.cityId];
        }
    }
    
    NSMutableString *dest = [[NSMutableString alloc] init];
    if (set.count) {
        for (NSString *s in set) {
            if (dest.length > 0) {
                [dest appendFormat:@"-%@", s];
            } else {
                [dest appendString:s];
            }
        }
    }
    else
    {
        [dest appendString:@""];
    }
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", titleStr, dest]];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:TEXT_COLOR_TITLE_SUBTITLE} range:NSMakeRange(titleStr.length, dest.length)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(titleStr.length, dest.length)];
    headerTitle.attributedText = attributeString;
    
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiOnEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poi_cell_of_edit" forIndexPath:indexPath];
    SuperPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    cell.poiNameLabel.text = tripPoi.zhName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - IBAction

- (IBAction)onScheduleChanged:(id)sender
{
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
