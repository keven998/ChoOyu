//
//  PTPlanDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTPlanDetailViewController.h"
#import "MyGuidesTableViewCell.h"

@interface PTPlanDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<MyGuideSummary *>* guideDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation PTPlanDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"方案详情";
    _tableView.separatorColor = COLOR_LINE;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"contentCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:@"myGuidesCell"];
    _guideDataSource = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    if (_guideDataSource.count) {
        return 3;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80 ;
        
    } else if (indexPath.section == 1) {
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"整套方案总价:  %ld\n\n", (NSInteger)_ptPlanDetail.totalPrice];
        [content appendString:_ptPlanDetail.desc];
        CGRect rect = [[[NSAttributedString alloc] initWithString:content] boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return rect.size.height+40;
        
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
        contentLabel.text = @"接单人";
    }
    if (section == 1) {
        contentLabel.text = @"方案详情";
    }
    if (section == 2) {
        contentLabel.text = @"方案行程";
    }
    [headerView addSubview:contentLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"userCell"];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.numberOfLines = 2;
            cell.detailTextLabel.textColor = COLOR_TEXT_II;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
            cell.imageView.layer.cornerRadius = cell.imageView.bounds.size.width/2;
            cell.imageView.clipsToBounds = YES;
            
            UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
            [chatButton setTitle:@"聊天" forState:UIControlStateNormal];
            [chatButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
            chatButton.layer.cornerRadius = 4.0;
            chatButton.layer.borderColor = APP_THEME_COLOR.CGColor;
            chatButton.layer.borderWidth = 0.5;
            chatButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [chatButton addTarget:self action:@selector(chatWithSeller) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = chatButton;
        }
        cell.textLabel.text = _ptPlanDetail.seller.nickName;
        cell.textLabel.text = @"卖家昵称\n";

        cell.detailTextLabel.text = [NSString stringWithFormat:@"在 %@ 号发布了需求", _ptPlanDetail.commitTimeStr];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_ptPlanDetail.seller.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentCell" forIndexPath:indexPath];
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.numberOfLines = 0;
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"整套方案总价:  %ld\n\n", (NSInteger)_ptPlanDetail.totalPrice];
        [content appendString:_ptPlanDetail.desc];
        cell.textLabel.text = content;
        return cell;
        
    } else {
        MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myGuidesCell" forIndexPath:indexPath];
        MyGuideSummary *summary = [_guideDataSource objectAtIndex:indexPath.row];
        if ([summary.status isEqualToString:@"traveled"]) {
            cell.markImageView.hidden = NO;
        } else {
            cell.markImageView.hidden = YES;
        }

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

@end
