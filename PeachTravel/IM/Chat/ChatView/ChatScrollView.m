//
//  ChatScrollView.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/6.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChatScrollView.h"

#define gap      10.0

#define itemWidth   40
#define itemHeigh   40

@interface ChatScrollView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) NSInteger countPerLine;
@property (nonatomic) NSInteger lineCount;


@end

@implementation ChatScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.9;
        CGRect scrollFrame = CGRectMake(0, 0, frame.size.width-100, frame.size.height);
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        self.addBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 10, 40, 40)];
        [self.addBtn setBackgroundImage:[UIImage imageNamed:@"add_contact.png"] forState:UIControlStateNormal];
        self.addBtn.layer.cornerRadius = 20;
        [self addSubview:self.addBtn];
        
        self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 95, 10, 40, 40)];
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"remove_contact.png"] forState:UIControlStateNormal];
        [self addSubview:self.deleteBtn];
        self.deleteBtn.layer.cornerRadius = 20;
        self.deleteBtn.hidden = YES;
        
        _countPerLine = (frame.size.width - 100)/(40+gap);
        _lineCount = (self.dataSource.count/_countPerLine);
        if (!_lineCount * _countPerLine == self.dataSource.count) {
            _lineCount++;
        }
        _dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-50, self.frame.size.height-50, 35, 35)];
        [_dismissBtn setTitle:@"隐藏" forState:UIControlStateNormal];
        [_dismissBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_up.png"] forState:UIControlStateNormal];
//        [self addSubview:_dismissBtn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setShouldshowDeleteBtn:(BOOL)shouldshowDeleteBtn
{
    _shouldshowDeleteBtn = shouldshowDeleteBtn;
    if (_shouldshowDeleteBtn && self.dataSource.count>0) {
        self.deleteBtn.hidden = NO;
    } else {
        self.deleteBtn.hidden = YES;
    }
}
- (void)setIsEditting:(BOOL)isEditting
{
    _isEditting = isEditting;
    [self setNeedsDisplay];
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    _lineCount = (self.dataSource.count/_countPerLine);
    if (!(_lineCount * _countPerLine == self.dataSource.count)) {
        _lineCount++;
    }
    if (dataSource.count<=0) {
        self.addBtn.hidden = NO;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, _lineCount*(60+gap)+30);
    
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    for (int i = 0; i<self.dataSource.count; i++) {
        CGFloat x = gap + i%_countPerLine*(gap+itemWidth);
        CGFloat y = gap + i/_countPerLine*(gap+itemHeigh+20);
        UIView *item = [self.dataSource objectAtIndex:i];
        CGRect frame = CGRectMake(x, y, itemWidth, itemHeigh);
        item.layer.cornerRadius = itemWidth/2;
        item.clipsToBounds = YES;
        item.frame = frame;

        [self.scrollView addSubview:item];
        
        UIView *button = [self.deleteBtns objectAtIndex:i];
        button.frame = CGRectMake(item.frame.origin.x, item.frame.origin.y, 40, 40);
        [self.scrollView addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y+itemHeigh, itemWidth, 20)];
        label.text = [_titles objectAtIndex:i];
        label.font = [UIFont systemFontOfSize:10.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:label];
    }

}

- (void)tap
{
    self.addBtn.hidden = NO;
    if (_shouldshowDeleteBtn && self.dataSource.count>0) {
        self.deleteBtn.hidden = NO;
    } else {
        self.deleteBtn.hidden = YES;
    }
    for (UIButton *btn in self.deleteBtns) {
        btn.hidden = YES;
    }
}


@end
