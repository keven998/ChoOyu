//
//  NSURL+TZURL.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/9/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (TZURL)

- (NSString *)parameterForKey:(NSString *)key;

- (NSDictionary  *)parameters;

@end
