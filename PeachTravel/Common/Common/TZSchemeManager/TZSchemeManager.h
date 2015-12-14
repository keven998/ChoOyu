//
//  TZSchemeManager.h
//  TestScheme
//
//  Created by liangpengshuai on 12/10/15.
//  Copyright © 2015 com.lps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TZSchemeManager : NSObject

- (void)handleUri:(NSString *)urlStr handleUriCompletionBlock:(void(^)(UIViewController *controller, NSString *uri))completionBlock;

@end
