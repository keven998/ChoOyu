//
//  ChatQuestionTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ChatQuestionTableViewCell.h"

@interface ChatQuestionTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QuestionMessage *questionMessage;

@end

@implementation ChatQuestionTableViewCell

- (void)awakeFromNib {
    [self.contentView addSubview:self.tableView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        _tableView.layer.cornerRadius = 4.0;
        _tableView.layer.borderColor = COLOR_LINE.CGColor;
        _tableView.layer.borderWidth = 1.0;
        _tableView.rowHeight = 44.0;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return _tableView;
}

- (void)setMessageModel:(MessageModel *)messageModel
{
    _messageModel = messageModel;
    _questionMessage = (QuestionMessage *)_messageModel.baseMessage;
    [self setNeedsDisplay];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = CGRectMake(10, 20, self.bounds.size.width-40, 44*_questionMessage.questionList.count);
    _tableView.frame = frame;
    [self.tableView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
    return cell;
}














@end
