//
//  ConvertMethods.h
//  lvxingpai
//
//  Created by Luo Yong on 14-6-25.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ConvertMethods : NSObject

+ (CLLocationDistance) getDistanceFrom:(CLLocationCoordinate2D)startPoint to:(CLLocationCoordinate2D)endPoint;

+ (NSString *)getCurrentDataWithFormat:(NSString *)format;
+ (NSString *)getCuttentData;
+ (NSDate *)stringToDate:(NSString *)string withFormat:(NSString *)format withTimeZone:(NSTimeZone *)zone;
+ (NSString *)dateToString:(NSDate *)date withFormat:(NSString *)format withTimeZone:(NSTimeZone *)zone;
+ (NSString *)timeIntervalToString:(long long)interval withFormat:(NSString *)format withTimeZone:(NSTimeZone *)zone;

+ (UIImage*) createImageWithColor: (UIColor*)color;
+ (UIColor *)RGBColor:(int)rgb withAlpha:(CGFloat)alpha;

+ (NSString *)generateQiniuImageUrl: (NSString *)url width:(int)w height:(int)h;

//得到手机上装的地图软件的名字
+ (NSArray *)getMapPlatformInPhone;

//sha1
+ (NSString *)sha1:(NSString *)str;

//将汉字转换为拼音
+ (NSString *)chineseToPinyin:(NSString *)chinese;


@end
