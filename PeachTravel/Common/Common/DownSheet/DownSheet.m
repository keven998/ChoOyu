//
//  DownSheet.m
//  audioWriting
//
//  Created by wolf on 14-7-19.
//  Copyright (c) 2014年 wangruiyy. All rights reserved.
//

#import "DownSheet.h"
@implementation DownSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithlist:(NSArray *)list height:(CGFloat)height andTitle:(NSString *)title
{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.backgroundColor = RGBACOLOR(160, 160, 160, 0);
        _title = title;
        CGFloat height = 0;
        if (title) {
            height = 50*[list count]+50;
           
        } else {
            height = 50*[list count];
        }
        view = [[UITableView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth,height) style:UITableViewStylePlain];
        view.dataSource = self;
        view.delegate = self;
        view.separatorColor = COLOR_LINE;
        listData = list;
        view.scrollEnabled = NO;
        [self addSubview:view];
        
        dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-60, ScreenHeight-20, 40, 40)];
        [dismissBtn setImage:[UIImage imageNamed:@"icon_downSheet_cancel.png"] forState:UIControlStateNormal];
        [dismissBtn addTarget:self action:@selector(willDismissSheet) forControlEvents:UIControlEventTouchUpInside];
        [dismissBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self addSubview:dismissBtn];
        
        [self animeData];

    }
    return self;
}

-(void)animeData{
   
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = RGBACOLOR(160, 160, 160, .4);
        [UIView animateWithDuration:.25 animations:^{
            [view setFrame:CGRectMake(view.frame.origin.x, ScreenHeight-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
            [dismissBtn setFrame:CGRectMake(dismissBtn.frame.origin.x, ScreenHeight-view.frame.size.height-20, dismissBtn.frame.size.width, dismissBtn.frame.size.height)];

        }];
    } completion:^(BOOL finished) {
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[self class]]){
        return YES;
    }
    return NO;
}

- (void)willDismissSheet
{
    if ([self.delegate respondsToSelector:@selector(shouldDismissSheet)]) {
        [self.delegate shouldDismissSheet];
    }
}

-(void)dismissSheet
{
    [UIView animateWithDuration:.25 animations:^{
        [view setFrame:CGRectMake(0, ScreenHeight,ScreenWidth, 0)];
        dismissBtn.frame = CGRectMake(ScreenWidth-60, ScreenHeight-20, 40, 40);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)showInView:(UIViewController *)Sview
{
    if(Sview==nil) {
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    } else {
    //[view addSubview:self];
        [Sview.view addSubview:self];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listData count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_title) {
        return 50;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, tableView.bounds.size.width-22, 50)];
    titleLabel.textColor = COLOR_TEXT_I;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = _title;
    [sectionHeader addSubview:titleLabel];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, sectionHeader.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [sectionHeader addSubview:spaceView];
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DownSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[DownSheetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setData:[listData objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(didSelectIndex:)]){
        [_delegate didSelectIndex:indexPath.row];
        return;
    }
}

@end


