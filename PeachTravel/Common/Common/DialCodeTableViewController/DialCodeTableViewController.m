//
//  DialCodeTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "DialCodeTableViewController.h"
#import "DialCodeTableViewCell.h"

@interface DialCodeTableViewController ()

@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation DialCodeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *backBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [backBtn setFrame:CGRectMake(0, 0, 40, 30)];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = barButton;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = COLOR_TEXT_II;
    self.navigationItem.title = @"选择国家和地区";
    [self.tableView registerNib:[UINib nibWithNibName:@"DialCodeTableViewCell" bundle:nil] forCellReuseIdentifier:@"dialCodeCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSDictionary *)dataSource
{
    if (!_dataSource) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DialCode" ofType:@"plist"];
        NSArray *dataSource = [[NSArray alloc] initWithContentsOfFile:filePath];
        _dataSource = [self groupByPinyinWithDatasource:dataSource];
    }
    return _dataSource;
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 22)];
    label.text = [NSString stringWithFormat:@"    %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section]];
    label.backgroundColor = APP_PAGE_COLOR;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = COLOR_TEXT_II;
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.dataSource objectForKey:@"headerKeys"] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSource objectForKey:@"content"] objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DialCodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dialCodeCell" forIndexPath:indexPath];
    cell.countryNameLabel.text = [dic objectForKey:@"countryName"];
    cell.dialCodeLabel.text = [NSString stringWithFormat:@"+%@", [dic objectForKey:@"dialCode"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(didSelectDialCode:)]) {
        NSDictionary *dic = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [_delegate didSelectDialCode:dic];
        [self goBack];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}

- (NSDictionary *)groupByPinyinWithDatasource:(NSArray *)dataSource
{
    // 定义一个数组存储排序后的拼音数组
    NSMutableArray *chineseStringsArray = [[NSMutableArray alloc] init];
    for (id tempContact in dataSource) {
        [chineseStringsArray addObject:tempContact];
    }
    
    NSMutableArray *sectionHeadsKeys = [[NSMutableArray alloc] init];
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"countryPY" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [[NSMutableArray alloc] init];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *tempArrForGrouping = nil;
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        NSDictionary *contact = [chineseStringsArray objectAtIndex:index];
        NSString *pingyin = [contact objectForKey:@"countryNamePY"];
        NSMutableString *strchar= [NSMutableString stringWithString:pingyin];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]]) {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            tempArrForGrouping = [[NSMutableArray alloc] init];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [tempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:tempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return @{@"headerKeys":sectionHeadsKeys, @"content":arrayForArrays};
}

@end
