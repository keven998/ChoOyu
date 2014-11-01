//
//  CreateCoversationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "CreateConversationViewController.h"
#import "TZScrollView.h"
#import "pinyin.h"
#import "AccountManager.h"

#define contactCell      @"contactCell"

@interface CreateConversationViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TZScrollView *tzScrollView;
@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;

@end

@implementation CreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tzScrollView];
    [self.view addSubview:self.contactTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - setter & getter

- (TZScrollView *)tzScrollView
{
    if (!_tzScrollView) {
        
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 144, [UIApplication sharedApplication].keyWindow.frame.size.width, 40)];
        _tzScrollView.scrollView.delegate = self;
        _tzScrollView.itemWidth = 80;
        _tzScrollView.itemHeight = 40;
        _tzScrollView.itemBackgroundColor = [UIColor greenColor];
        _tzScrollView.backgroundColor = [UIColor greenColor];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i<[[self.dataSource objectForKey:@"headerKeys"] count]; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            NSString *s = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:i];
            [button setTitle:s forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor greenColor]];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            button.tag = i;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [array addObject:button];
        }
        _tzScrollView.viewsOnScrollView = array;
        for (UIButton *tempBtn in _tzScrollView.viewsOnScrollView) {
            [tempBtn addTarget:self action:@selector(choseCurrent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _tzScrollView;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.tzScrollView.frame.origin.y+self.tzScrollView.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height-self.tzScrollView.frame.origin.y - self.tzScrollView.frame.size.height)];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        [_contactTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:contactCell];
    }
    return _contactTableView;
}

- (NSDictionary *)dataSource
{
    if (!_dataSource) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        _dataSource = [accountManager contactsByPinyin];
    }
    return _dataSource;
}

#pragma mark - IBAction Methods

- (IBAction)choseCurrent:(UIButton *)sender
{
    _tzScrollView.currentIndex = sender.tag;
    [self tableViewMoveToCorrectPosition:sender.tag];
}

#pragma mark - Private Methods

- (void)tableViewMoveToCorrectPosition:(NSInteger)currentIndex
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndex];
    [self.contactTableView scrollToRowAtIndexPath:scrollIndexPath
                                 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UITableVeiwDataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.backgroundColor = [UIColor grayColor];
    
    label.text = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section];
    return label;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *contacts = [[self.dataSource objectForKey:@"content"] objectAtIndex:section];
    return [contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
    cell.textLabel.text = contact.nickName;
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        
        NSLog(@"offset: %@", NSStringFromCGPoint(currentOffset));
        
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > [[self.dataSource objectForKey:@"headerKeys"] count]-1) {
            currentIndex = [[self.dataSource objectForKey:@"headerKeys"] count]-1;
        }
        if (currentIndex < 0) {
            currentIndex = 0;
        }
        _tzScrollView.currentIndex = currentIndex;
        [self tableViewMoveToCorrectPosition:currentIndex];
        
    } else if (scrollView == self.contactTableView) {
        NSArray *visiableCells = [self.contactTableView visibleCells];
        NSIndexPath *indexPath = [self.contactTableView indexPathForCell:[visiableCells firstObject]];
        self.tzScrollView.currentIndex = indexPath.section;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > [[self.dataSource objectForKey:@"headerKeys"] count]-1) {
            currentIndex = [[self.dataSource objectForKey:@"headerKeys"] count]-1;
        }
        if (currentIndex < 0) {
            currentIndex = 0;
        }
        _tzScrollView.currentIndex = currentIndex;
        [self tableViewMoveToCorrectPosition:currentIndex];
        
    } else if (scrollView == self.contactTableView) {
        NSArray *visiableCells = [self.contactTableView visibleCells];
        NSIndexPath *indexPath = [self.contactTableView indexPathForCell:[visiableCells firstObject]];
        self.tzScrollView.currentIndex = indexPath.section;
    }
}


@end
