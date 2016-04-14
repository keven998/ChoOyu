//
//  PTMakePlanViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/12/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTMakePlanViewController.h"
#import "PTMakePlanContenTableViewCell.h"
#import "MyGuidesTableViewCell.h"
#import "PlansListTableViewController.h"
#import "PersonalTailorManager.h"

@interface PTMakePlanViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SWTableViewCellDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<MyGuideSummary *>* guideDataSource;
@property (nonatomic, copy) NSString *planContent;
@property (nonatomic) NSInteger totalPrice;

@end

@implementation PTMakePlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.separatorColor = COLOR_LINE;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.navigationItem.title = @"制作方案";
    [_tableView registerNib:[UINib nibWithNibName:@"PTMakePlanContenTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTMakePlanContenTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:@"myGuidesCell"];
    _guideDataSource = [[NSMutableArray alloc] init];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 80)];
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, kWindowWidth-40, 40)];
    commitButton.layer.cornerRadius = 5.0;
    commitButton.clipsToBounds = YES;
    [commitButton setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_PRICE_RED] forState:UIControlStateNormal];
    [commitButton setTitle:@"提交方案" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitPlane:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:commitButton];
    _tableView.tableFooterView = footerView;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)commitPlane:(UIButton *)sender
{
    if (!_planContent.length) {
        [SVProgressHUD showHint:@"请输入方案内容"];
        return;
    }
    if (!_totalPrice) {
        [SVProgressHUD showHint:@"请输入方案金额"];
        return;
    }
    NSMutableArray *guidesId = [[NSMutableArray alloc] init];
    for (MyGuideSummary *guide in _guideDataSource) {
        [guidesId addObject:guide.guideId];
    }
    [PersonalTailorManager asyncMakePlanForPTWithPtId:_ptId content:_planContent totalPrice:_totalPrice guideList:guidesId completionBlock:^(BOOL isSuccess) {
        
    }];
    
}

- (void)addPlan:(UIButton *)sender
{
    PlansListTableViewController *ctl = [[PlansListTableViewController alloc] init];
    ctl.userId = [AccountManager shareAccountManager].account.userId;
    ctl.userName = [AccountManager shareAccountManager].account.nickName;
    ctl.canSelect = YES;
    ctl.selectGuides = _guideDataSource;
    [self.navigationController pushViewController:ctl animated:YES];
}

// 侧边栏的按钮
- (NSArray *)rightButtonsWithIndexPath:(NSIndexPath *)path
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    NSDictionary * markDict = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0]};
    
    NSAttributedString * attributeDelete = [[NSAttributedString alloc] initWithString:@"删除" attributes:markDict];
    [rightUtilityButtons sw_addUtilityButtonWithColor:TZColor(245, 54, 82) attributedTitle:attributeDelete];
    
    return rightUtilityButtons;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return _guideDataSource.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 200;
    } else if (indexPath.section == 1) {
        return 49;
    } else if (indexPath.section == 2) {
        return 136;
    }
    return 49;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 40)];
    contentLabel.textColor = COLOR_TEXT_I;
    contentLabel.font = [UIFont systemFontOfSize:16.0];
    if (section == 0) {
        contentLabel.text = @"旅游方案描述";
    }
    if (section == 1) {
        contentLabel.text = @"整套方案价格";
    }
    if (section == 2) {
        contentLabel.text = @"智能定制行程";
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-90, 0, 70, 40)];
        [addButton setTitle:@"添加行程" forState:UIControlStateNormal];
        addButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [addButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addPlan:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:addButton];
    }
    [headerView addSubview:contentLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PTMakePlanContenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakePlanContenTableViewCell" forIndexPath:indexPath];
        cell.contentTextView.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOne"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellOne"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, kWindowWidth-80, 49)];
            tf.placeholder = @"输入价格";
            tf.textColor = COLOR_TEXT_II;
            tf.font = [UIFont systemFontOfSize:16.0];
            tf.delegate = self;
            tf.returnKeyType = UIReturnKeyDone;
            tf.textAlignment = NSTextAlignmentRight;
            [cell addSubview:tf];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-40, 0, 40, 49)];
            label.textColor = COLOR_TEXT_II;
            label.text = @"元";
            [cell addSubview:label];

        }
        return cell;
    } else {
        MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myGuidesCell" forIndexPath:indexPath];
        MyGuideSummary *summary = [_guideDataSource objectAtIndex:indexPath.row];
        if ([summary.status isEqualToString:@"traveled"]) {
            cell.markImageView.hidden = NO;
        } else {
            cell.markImageView.hidden = YES;
        }
        cell.rightUtilityButtons = [self rightButtonsWithIndexPath:indexPath];
        cell.delegate = self;
        cell.guideSummary = summary;
        cell.isCanSend = NO;
        cell.tag = indexPath.row;
        TaoziImage *image = [summary.images firstObject];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        
        cell.titleBtn.attributedText = nil;
        cell.titleBtn.text = summary.title;
        cell.playedBtn.hidden = YES;
        cell.deleteBtn.hidden = YES;
            
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _totalPrice = [textField.text integerValue];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _planContent = textView.text;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            [_guideDataSource removeObjectAtIndex:cell.tag];
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }
}

@end



