//
//  CallViewController.h
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-9-24.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    CommunicationStatusNone,
    CommunicationStatusCallOuting,
    CommunicationStatusCallIning,
    CommunicationStatusAnswering,
    CommunicationStatusAnother,
}CommunicationStatus;

@interface CallViewController : TZViewController

+ (instancetype)shareController;

- (void)setupCallOutWithChatter:(NSString *)chatter;
- (void)setupCallInWithChatter:(NSString *)chatter;

@end
