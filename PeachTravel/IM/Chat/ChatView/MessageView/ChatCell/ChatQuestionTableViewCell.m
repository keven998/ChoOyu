//
//  ChatQuestionTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ChatQuestionTableViewCell.h"

@interface ChatQuestionTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) QuestionMessage *questionMessage;

@end

@implementation ChatQuestionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = APP_PAGE_COLOR;
        [self addSubview:self.tableView];
        self.userInteractionEnabled = YES;
    }
    return self;
    
}

- (UITableView *)tableView
{
    if (!_tableView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableSelected:)];
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        _tableView.layer.cornerRadius = 4.0;
        _tableView.layer.borderColor = COLOR_LINE.CGColor;
        _tableView.separatorColor = COLOR_LINE;
        _tableView.layer.borderWidth = 1.0;
        _tableView.rowHeight = 44.0;
        _tableView.userInteractionEnabled = YES;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (void)setMessageModel:(MessageModel *)messageModel
{
    _messageModel = messageModel;
    _questionMessage = (QuestionMessage *)_messageModel.baseMessage;
    [self setNeedsDisplay];
}

- (void)tableSelected:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:location];
    [self tableView:_tableView didSelectRowAtIndexPath:path];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = CGRectMake(20, 20, self.bounds.size.width-40, 44*_questionMessage.questionList.count);
    _tableView.frame = frame;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _questionMessage.questionList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    QuestionModel *questionModel = _questionMessage.questionList[indexPath.row];
    cell.textLabel.text = questionModel.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = COLOR_TEXT_I;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QuestionModel *questionModel = _questionMessage.questionList[indexPath.row];
    [_delegate chatQuestionTableCellDidSelectedWithQuestionModel:questionModel];
}

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)model
{
    return 40 + 44*((QuestionMessage *)model.baseMessage).questionList.count;
}


@end
