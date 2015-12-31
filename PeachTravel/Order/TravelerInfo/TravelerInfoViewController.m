//
//  TravelerInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/16/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TravelerInfoViewController.h"
#import "OrderUserInfoManager.h"
#import "DialCodeTableViewController.h"

@interface TravelerInfoViewController () <UITextFieldDelegate, UIActionSheetDelegate, DialCodeTableViewControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *firstNameTextField;
@property (nonatomic, strong) UITextField *lastNameTextField;
@property (nonatomic, strong) UIButton *dialCodeButton;
@property (nonatomic, strong) UITextField *telTextField;
@property (nonatomic, strong) UIButton *IDNumberCategoryButton;
@property (nonatomic, strong) UITextField *IDNumberTextField;

@end

@implementation TravelerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *commintBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [commintBtn setTitle:@"完成" forState:UIControlStateNormal];
    commintBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [commintBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commintBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [commintBtn addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:commintBtn];

    if (_isEditTravelerInfo) {
        self.navigationItem.title = @"编辑旅客信息";
        self.navigationItem.rightBarButtonItem = rightItem;
        
    }  else if (_isAddTravelerInfo) {
        self.navigationItem.title = @"添加旅客信息";
        self.navigationItem.rightBarButtonItem = rightItem;
        _traveler = [[OrderTravelerInfoModel alloc] init];
        _traveler.IDCategory = @"chineseID";
        
    } else {
        self.navigationItem.title = @"旅客信息";
        self.view.userInteractionEnabled = NO;
    }
    
    NSArray *titleArray = @[@"姓(英文)", @"名(英文)", @"证件类型", @"证件号码", @"电话"];

    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1);
    [self.view addSubview:_scrollView];
    UIView *rowSpaceView = [[UIView alloc] initWithFrame:CGRectMake(106, 0, 0.5, titleArray.count*48)];
    rowSpaceView.backgroundColor = COLOR_LINE;
    [_scrollView addSubview:rowSpaceView];
    
    for (int i=0; i<titleArray.count; i++) {
        NSString *title = [titleArray objectAtIndex:i];
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, i*48-0.5, kWindowWidth, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [_scrollView addSubview:spaceView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, i*48, 85, 48)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = COLOR_TEXT_I;
        titleLabel.text = title;
        [_scrollView addSubview:titleLabel];
    }
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, rowSpaceView.bounds.size.height, kWindowWidth, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [_scrollView addSubview:spaceView];
    
    _lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(126, 10, (kWindowWidth-106)-40, 28)];
    _lastNameTextField.placeholder = @"Last Name,如Zhang";
    _lastNameTextField.font = [UIFont systemFontOfSize:15];
    _lastNameTextField.textColor = COLOR_TEXT_III;
    _lastNameTextField.returnKeyType = UIReturnKeyDone;
    _lastNameTextField.delegate = self;
    _lastNameTextField.text = _traveler.lastName;
    [_scrollView addSubview:_lastNameTextField];
    
    _firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(126, 10+48, (kWindowWidth-106)-40, 28)];
    _firstNameTextField.placeholder = @"First Name,如Xiaoxiao";
    _firstNameTextField.font = [UIFont systemFontOfSize:15];
    _firstNameTextField.textColor = COLOR_TEXT_III;
    _firstNameTextField.returnKeyType = UIReturnKeyDone;
    _firstNameTextField.delegate = self;
    _firstNameTextField.text = _traveler.firstName;
    [_scrollView addSubview:_firstNameTextField];
    
    _IDNumberCategoryButton = [[UIButton alloc] initWithFrame:CGRectMake(126, 10+48*2, (kWindowWidth-106)-60, 28)];
    [_IDNumberCategoryButton setBackgroundImage:[[UIImage imageNamed:@"icon_travelerInfo_selectIDCategory"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 30)] forState:UIControlStateNormal];
    [_IDNumberCategoryButton addTarget:self action:@selector(choseIDCategory:) forControlEvents:UIControlEventTouchUpInside];
    _IDNumberCategoryButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _IDNumberCategoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_IDNumberCategoryButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [_IDNumberCategoryButton setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
    [_IDNumberCategoryButton setTitle:_traveler.IDCategoryDesc forState:UIControlStateNormal];
    [_scrollView addSubview:_IDNumberCategoryButton];
    
    _IDNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(126, 10+48*3, (kWindowWidth-106)-40, 28)];
    _IDNumberTextField.placeholder = @"证件号码";
    _IDNumberTextField.font = [UIFont systemFontOfSize:15];
    _IDNumberTextField.textColor = COLOR_TEXT_III;
    _IDNumberTextField.returnKeyType = UIReturnKeyDone;
    _IDNumberTextField.delegate = self;
    _IDNumberTextField.text = _traveler.IDNumber;
    [_scrollView addSubview:_IDNumberTextField];
    
    _dialCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(126, 10+48*4, 40, 28)];
    [_dialCodeButton addTarget:self action:@selector(choseDialCode:) forControlEvents:UIControlEventTouchUpInside];
    _dialCodeButton.layer.borderColor = COLOR_LINE.CGColor;
    _dialCodeButton.layer.borderWidth = 0.5;
    _dialCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_dialCodeButton setTitle:[NSString stringWithFormat:@"+%@", _traveler.dialCode] forState:UIControlStateNormal];
    [_dialCodeButton setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
    _dialCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_scrollView addSubview:_dialCodeButton];
    
    _telTextField = [[UITextField alloc] initWithFrame:CGRectMake(170, 10+48*4, (kWindowWidth-106)-85, 28)];
    _telTextField.text = _traveler.telNumber;
    _telTextField.placeholder = @"电话";
    _telTextField.font = [UIFont systemFontOfSize:15];
    _telTextField.textColor = COLOR_TEXT_III;
    _telTextField.returnKeyType = UIReturnKeyDone;
    _telTextField.keyboardType = UIKeyboardTypeNumberPad;
    _telTextField.delegate = self;
    [_scrollView addSubview:_telTextField];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTraveler:(OrderTravelerInfoModel *)traveler
{
    _traveler = traveler;
}

- (IBAction)choseDialCode:(id)sender
{
    DialCodeTableViewController *ctl = [[DialCodeTableViewController alloc] init];
    ctl.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentViewController:navi animated:YES completion:nil];
}

- (IBAction)finishEdit:(id)sender
{
    _traveler.firstName = _firstNameTextField.text;
    _traveler.lastName = _lastNameTextField.text;
    _traveler.telNumber = _telTextField.text;
    _traveler.IDNumber = _IDNumberTextField.text;
    NSString *dialCode = [_dialCodeButton.titleLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    _traveler.dialCode = dialCode;
    if ([OrderUserInfoManager checkTravelerInfoIsComplete:_traveler]) {
        [SVProgressHUD showHint:[OrderUserInfoManager checkTravelerInfoIsComplete:_traveler]];
        
    } else {
        if (_isAddTravelerInfo) {
            [OrderUserInfoManager asyncAddTraveler:_traveler completionBlock:^(BOOL isSuccess, OrderTravelerInfoModel *traveler) {
                if (isSuccess) {
                    [SVProgressHUD showHint:@"添加成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [SVProgressHUD showHint:@"添加失败"];
                }
            }];
        } else {
            [OrderUserInfoManager asyncEditTraveler:_traveler completionBlock:^(BOOL isSuccess, OrderTravelerInfoModel *traveler) {
                if (isSuccess) {
                    [SVProgressHUD showHint:@"修改成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [SVProgressHUD showHint:@"修改失败"];
                }
            }];
        }
    }
}

- (void)choseIDCategory:(UIButton *)sender
{
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择证件类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"护照", @"身份证", @"港澳通行证", @"大陆居民往来台湾通行证 ", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        _traveler.IDCategory = @"passport";
        
    } else if (buttonIndex == 1) {
        _traveler.IDCategory = @"chineseID";

    }
    [_IDNumberCategoryButton setTitle:_traveler.IDCategoryDesc forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

#pragma mark - DialCodeTableViewControllerDelegate

- (void)didSelectDialCode:(NSDictionary *)dialCode
{
    if (dialCode) {
        [_dialCodeButton setTitle:[NSString stringWithFormat:@"+%@", [dialCode objectForKey:@"dialCode"]] forState:UIControlStateNormal];
        
    }
}

@end
