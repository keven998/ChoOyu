//
//  FavoriteViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteTableViewCell.h"

@interface FavoriteViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) FavoriteTableViewCell *prototypeCell;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"收藏夹";
    
    _selectedIndex = -1;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.contentInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"favorite_cell"];
    [self.view addSubview:_tableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    
    cell.standardImageView.image = [UIImage imageNamed:@"country.jpg"];
    cell.contentType.text = @"景点";
    cell.contentTitle.text = @"黄果树瀑布";
    cell.contentLocation.text = @"安顺";
    cell.contentTypeFlag.image = [UIImage imageNamed:@"ic_gender_man.png"];
    [cell.contentDescExpandView setTitle:@"hellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohello" forState:UIControlStateNormal];
    
    [cell.contentDescExpandView addTarget:self action:@selector(expandDesc:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)expandDesc:(id)sender {
    UIButton *btn = sender;
    CGPoint viewPos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
    
    if (_selectedIndex != -1 && _selectedIndex != indexPath.row) {
        NSIndexPath *pi = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        FavoriteTableViewCell *pc = (FavoriteTableViewCell *)[_tableView cellForRowAtIndexPath:pi];
        pc.contentDescExpandView.selected = NO;
    }
    
    if (!btn.isSelected) {
        _selectedIndex = indexPath.row;
        btn.selected = YES;
    } else {
        _selectedIndex = -1;
        btn.selected = NO;
    }
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text = @"hellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohello";
    
    if (indexPath.row == _selectedIndex) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
        return 200 + rect.size.height - 30 + 20.0;
    }
    return 204.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
