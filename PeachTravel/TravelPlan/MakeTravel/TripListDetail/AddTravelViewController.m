//
//  AddTravelViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//



#import "AddTravelViewController.h"
#import "UUDatePicker.h"
#import "PlanTravelModel.h"



@interface AddTravelViewController () <UUDatePickerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) UITextField *numberLabel;
@property (nonatomic, strong) UITextField *startPointTF;
@property (nonatomic, strong) UITextField *endPointTF;
@property (nonatomic, strong) UIButton *endDateButton;
@property (nonatomic, strong) UIButton *startDateButton;

@property (nonatomic, strong) UUDatePicker *datePicker;
@property (nonatomic, strong) UIButton *currentDateButton;
@property (nonatomic, strong) PlanTravelModel *trafficModel;


@end

@implementation AddTravelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    _seg = [[UISegmentedControl alloc] initWithItems:@[@" 飞机 ",  @" 火车 ", @" 其他 "]];
    [_seg addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventValueChanged];
    _seg.selectedSegmentIndex = 0;
    self.navigationItem.titleView = _seg;
    [self renderView];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)changeType:(UISegmentedControl *)ctl
{
    [self renderView];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveEdit
{
    [self.view endEditing:YES];
    if (_numberLabel.text.length == 0) {
        [SVProgressHUD showHint:@"请输入交通班次"];
        return;
    }
    if (_startPointTF.text.length == 0) {
        [SVProgressHUD showHint:@"请输入出发地"];
        return;
    }
    if (_endPointTF.text.length == 0) {
        [SVProgressHUD showHint:@"请输入目的地"];
        return;
    }
    _trafficModel = [[PlanTravelModel alloc] init];
    if (_seg.selectedSegmentIndex == 0) {
        _trafficModel.type = @"airline";
    }
    if (_seg.selectedSegmentIndex == 1) {
        _trafficModel.type = @"trainRoute";
    }
    if (_seg.selectedSegmentIndex == 2) {
        _trafficModel.type = @"other";
    }
    _trafficModel.trafficName = _numberLabel.text;
    _trafficModel.startPointName = _startPointTF.text;
    _trafficModel.endPointName = _endPointTF.text;
    _trafficModel.startDate = _startDateButton.titleLabel.text;
    _trafficModel.endDate = _endDateButton.titleLabel.text;
    [_delegate endEditTravel:_trafficModel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)renderView
{
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(12, 84, kWindowWidth-24, 230)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 4.0;
    _contentView.clipsToBounds = YES;
    [self.view addSubview:_contentView];
    
    CGFloat width = _contentView.bounds.size.width;
    
    _numberLabel = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, width-40, 30)];
    if (_seg.selectedSegmentIndex == 0) {
        _numberLabel.placeholder = @"飞机航班";
    }
    if (_seg.selectedSegmentIndex == 1) {
        _numberLabel.placeholder = @"火车车次";
    }
    if (_seg.selectedSegmentIndex == 2) {
        _numberLabel.placeholder = @"其他交通";
    }
    _numberLabel.textColor = COLOR_TEXT_I;
    _numberLabel.font = [UIFont systemFontOfSize:15.0];
    [_contentView addSubview:_numberLabel];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(20, 60, width-40, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [_contentView addSubview:spaceView];
    
    _startPointTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, (width-60)/2, 30)];
    _startPointTF.placeholder = @"起点";
    _startPointTF.textColor = COLOR_TEXT_I;
    _startPointTF.font = [UIFont systemFontOfSize:15.0];
    [_contentView addSubview:_startPointTF];
    
    UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(20, 120, (width-60)/2, 0.5)];
    spaceView1.backgroundColor = COLOR_LINE;
    [_contentView addSubview:spaceView1];
    
    _endPointTF = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_startPointTF.frame)+20, 80, (width-60)/2, 30)];
    _endPointTF.placeholder = @"终点";
    _endPointTF.textColor = COLOR_TEXT_I;
    _endPointTF.font = [UIFont systemFontOfSize:15.0];
    [_contentView addSubview:_endPointTF];
    
    UIView *spaceView2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_startPointTF.frame)+20, 120, (width-60)/2, 0.5)];
    spaceView2.backgroundColor = COLOR_LINE;
    [_contentView addSubview:spaceView2];
    
    _startDateButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 170, (width-60)/2, 40)];
    [_startDateButton setTitle:@"未选择" forState:UIControlStateNormal];
    [_startDateButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_startDateButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    _startDateButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_startDateButton addTarget:self action:@selector(choseDateAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_startDateButton];
    
    UILabel *startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, (width-60)/2, 20)];
    startDateLabel.text = @"出发日期";
    startDateLabel.textColor = COLOR_TEXT_II;
    startDateLabel.font =  [UIFont systemFontOfSize:15.0];
    [_contentView addSubview:startDateLabel];
    
    _endDateButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_startPointTF.frame)+20, 170, (width-60)/2, 40)];
    [_endDateButton setTitle:@"未选择" forState:UIControlStateNormal];
    [_endDateButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_endDateButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _endDateButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_endDateButton addTarget:self action:@selector(choseDateAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_endDateButton];
    
    UILabel *endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_startPointTF.frame)+20, 150, (width-60)/2, 20)];
    endDateLabel.text = @"到达日期";
    endDateLabel.textColor = COLOR_TEXT_II;
    endDateLabel.font =  [UIFont systemFontOfSize:15.0];
    [_contentView addSubview:endDateLabel];
}

- (void)choseDateAction:(UIButton *)sender
{
    _currentDateButton = sender;
    [self.view endEditing:YES];
    if (_datePicker) {
        [_datePicker removeFromSuperview];
        _datePicker = nil;
    }
    _datePicker= [[UUDatePicker alloc]initWithframe:CGRectMake((kWindowWidth-320)/2, kWindowHeight, 320, 200)
                                                    Delegate:self
                                                 PickerStyle:UUDateStyle_YearMonthDayHourMinute];
    _datePicker.ScrollToDate = [NSDate date];
    _datePicker.maxLimitDate = [[NSDate date] dateByAddingTimeInterval:111111111];
    _datePicker.minLimitDate = [[NSDate date] dateByAddingTimeInterval:-111111111];
    [self.view addSubview:_datePicker];
    [UIView animateWithDuration:0.3 animations:^{
        _datePicker.frame = CGRectMake((kWindowWidth-320)/2, kWindowHeight-200, 320, 200);
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UUDatePicker's delegate

- (void)uuDatePicker:(UUDatePicker *)datePicker
                year:(NSString *)year
               month:(NSString *)month
                 day:(NSString *)day
                hour:(NSString *)hour
              minute:(NSString *)minute
             weekDay:(NSString *)weekDay
{
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", year, month, day, hour, minute];
    [_currentDateButton setTitle:dateStr forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_datePicker) {
        [_datePicker removeFromSuperview];
        _datePicker = nil;
    }
    [self.view endEditing:YES];
}


@end






