//
//  SelectPayPlatformViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "SelectPayPlatformViewController.h"
#import "SelectPayPlatformTableViewCell.h"
#import "TZPayManager.h"

@interface SelectPayPlatformViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSArray *titleList;
@property (nonatomic) NSInteger selectIndex;


@end

@implementation SelectPayPlatformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"付款方式";
    _selectIndex = 0;
    _titleList = @[@"支付宝", @"微信"];
    _imageList = @[@"icon_pay_alipay", @"icon_pay_wechat"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50.0;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"SelectPayPlatformTableViewCell" bundle:nil] forCellReuseIdentifier:@"selectPayPlatformCell"];
    [self setToolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setToolbar
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, toolBar.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [toolBar addSubview:spaceView];
    UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(toolBar.bounds.size.width-100, 6, 90, 37)];
    [payButton setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
    payButton.layer.cornerRadius = 4.0;
    payButton.clipsToBounds = YES;
    payButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [payButton setTitle:@"立即支付" forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(payOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:payButton];
    
    UILabel *priceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 40, toolBar.bounds.size.height)];
    priceTitleLabel.textColor = COLOR_TEXT_III;
    priceTitleLabel.font = [UIFont systemFontOfSize:14.0];
    priceTitleLabel.text = @"总价:";
    [toolBar addSubview:priceTitleLabel];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 0, 90, toolBar.bounds.size.height)];
    priceLabel.textColor = UIColorFromRGB(0xFC4E27);;
    priceLabel.font = [UIFont systemFontOfSize:17.0];
    priceLabel.text = @"100";
    [toolBar addSubview:priceLabel];
    
    [self.view addSubview:toolBar];
}

- (void)changePlatform:(UIButton *)sender
{
    _selectIndex = sender.tag;
    [_tableView reloadData];
}

- (IBAction)payOrderAction:(id)sender
{
    TZPayManager *payManager = [[TZPayManager alloc] init];
    [payManager asyncPayOrder:_orderDetail.orderId payPlatform:kWeichat completionBlock:^(BOOL isSuccess, NSString *errorStr) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
    titleLabel.text = @"   选择支付方式";
    titleLabel.textColor = COLOR_TEXT_I;
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    [view addSubview:titleLabel];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height-0.5, view.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [view addSubview:spaceView];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectPayPlatformTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectPayPlatformCell" forIndexPath:indexPath];
    cell.selectButton.selected = (indexPath.row == _selectIndex);
    cell.selectButton.tag = indexPath.row;
    [cell.headerImageView setImage:[UIImage imageNamed:[_imageList objectAtIndex:indexPath.row]]];
    cell.titleLabel.text = _titleList[indexPath.row];
    [cell.selectButton addTarget:self action:@selector(changePlatform:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}



@end
