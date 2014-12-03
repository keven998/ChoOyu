//
//  TaoziChatMessageBaseViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/2/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziChatMessageBaseViewController.h"

@interface TaoziChatMessageBaseViewController ()

@end

@implementation TaoziChatMessageBaseViewController

- (id)initWithChatMessageType:(TZChatType)chatType
{
    if (self = [super init]) {
        switch (chatType) {
            case TZChatTypeSpot:
                _titleLabel.text = @"景点";
                _addressLabel.hidden = YES;
                _ratingBtn.hidden = YES;
                
                break;
                
            case TZChatTypeCity:
                _titleLabel.text = @"城市";
                _addressLabel.hidden = YES;
                _ratingBtn.hidden = YES;
                
                break;
            
            case TZChatTypeFood:
                _titleLabel.text = @"美食";
                _descLabel.hidden = YES;
                
                break;
            
            case TZChatTypeHotel:
                _titleLabel.text = @"酒店";
                _descLabel.hidden = YES;

                break;
            
            case TZChatTypeShopping:
                _titleLabel.text = @"购物";
                _descLabel.hidden = YES;
                
            default:
                break;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)confirmSend:(UIButton *)sender {
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:_chatter isGroup:_isGroup];
    chatCtl.title = _chatTitle;
    [_delegate sendSuccess:chatCtl];
}

- (IBAction)cancel:(UIButton *)sender {
    [_delegate sendCancel];
}


@end
