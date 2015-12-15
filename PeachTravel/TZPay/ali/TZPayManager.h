//
//  TZPayManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

typedef enum : NSUInteger {
    kWeichat = 1,
    kAlipay,
    
} TZPayPlatform;

#import <Foundation/Foundation.h>



@interface TZPayManager : NSObject

- (void)asyncPayOrder:(NSInteger)orderId payPlatform:(TZPayPlatform)payPlatform completionBlock:(void (^) (BOOL isSuccess, NSString *errorStr))completion;

@end
