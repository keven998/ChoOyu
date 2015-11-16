//
//  TravelerInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/16/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TravelerInfoViewController.h"

@interface TravelerInfoViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *firstNameTextField;
@property (nonatomic, strong) UITextField *lastNameTextField;
@property (nonatomic, strong) UITextField *firstNamePYTextField;
@property (nonatomic, strong) UITextField *lastNamePYTextField;
@property (nonatomic, strong) UIButton *maleButton;
@property (nonatomic, strong) UIButton *femaleButton;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) UITextField *telTextField;
@property (nonatomic, strong) UITextField *IDNmuberTextField;

@end

@implementation TravelerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isEditTravelerInfo) {
        self.navigationItem.title = @"编辑旅客信息";
    } else {
        self.navigationItem.title = @"旅客信息";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    UIView *rowSpaceView = [[UIView alloc] initWithFrame:CGRectMake(106, 0, 0.5, 336)];
    rowSpaceView.backgroundColor = COLOR_LINE;
    [_scrollView addSubview:rowSpaceView];
    
    NSArray *titleArray = @[@"姓", @"名", @"性别", @"出生日期", @"电话", @"证件类型", @"证件号码"];
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
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 335.5, kWindowWidth, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [_scrollView addSubview:spaceView];
    
    _firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(126, 10, (kWindowWidth-106)/2-40, 28)];
    _firstNameTextField.placeholder = @"姓";
    _firstNameTextField.font = [UIFont systemFontOfSize:15];
    _firstNameTextField.textColor = COLOR_TEXT_III;
    _firstNameTextField.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_firstNameTextField];
    
    
    _firstNamePYTextField = [[UITextField alloc] initWithFrame:CGRectMake((kWindowWidth-106)/2+106+20, 10, (kWindowWidth-106)/2-40, 28)];
    _firstNamePYTextField.placeholder = @"拼音";
    _firstNamePYTextField.font = [UIFont systemFontOfSize:15];
    _firstNamePYTextField.textColor = COLOR_TEXT_III;
    _firstNamePYTextField.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_firstNamePYTextField];
    
    _lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(126, 10+49, (kWindowWidth-106)/2-40, 28)];
    _lastNameTextField.placeholder = @"名";
    _lastNameTextField.font = [UIFont systemFontOfSize:15];
    _lastNameTextField.textColor = COLOR_TEXT_III;
    _lastNameTextField.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_lastNameTextField];
    
    _lastNamePYTextField = [[UITextField alloc] initWithFrame:CGRectMake((kWindowWidth-106)/2+106+20, 10+49, (kWindowWidth-106)/2-40, 28)];
    _lastNamePYTextField.placeholder = @"拼音";
    _lastNamePYTextField.font = [UIFont systemFontOfSize:15];
    _lastNamePYTextField.textColor = COLOR_TEXT_III;
    _lastNamePYTextField.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_lastNamePYTextField];
    
    _maleButton = [[UIButton alloc] initWithFrame:CGRectMake(126, 48*2, 60, 48)];
    [_maleButton setImage:[UIImage imageNamed:@"icon_travelerInfo_sex_selected"] forState:UIControlStateSelected];
    [_maleButton setTitle:@"男" forState:UIControlStateNormal];
    _maleButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_maleButton setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
    _maleButton.tag = 1;
    _maleButton.selected = YES;
    [_maleButton addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_maleButton];
    
    _femaleButton = [[UIButton alloc] initWithFrame:CGRectMake(226, 48*2, 60, 48)];
    [_femaleButton setImage:[UIImage imageNamed:@"icon_travelerInfo_sex_selected"] forState:UIControlStateSelected];
    [_femaleButton setTitle:@"女" forState:UIControlStateNormal];
    _femaleButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_femaleButton setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
    _femaleButton.tag = 2;
    [_femaleButton addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_femaleButton];
    
    UIView *nameSpaceView = [[UIView alloc] initWithFrame:CGRectMake((kWindowWidth-106)/2+106, 0, 0.5, 96)];
    nameSpaceView.backgroundColor = COLOR_LINE;
    [_scrollView addSubview:nameSpaceView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)changeSex:(UIButton *)sender
{
    _maleButton.selected = !_maleButton.selected;
    _femaleButton.selected = !_femaleButton.selected;
}

@end
