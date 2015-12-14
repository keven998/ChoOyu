//
//  SchemeManager.h
//  TestScheme
//
//  Created by liangpengshuai on 12/8/15.
//  Copyright © 2015 com.lps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SchemeManager : NSObject

@property (nonatomic, copy) void (^parserCompletionBlock)(UIViewController *controller);

@end
