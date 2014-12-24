//
//  ConvertMethods.m
//  lvxingpai
//
//  Created by Luo Yong on 14-6-25.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "ConvertMethods.h"
#import <CommonCrypto/CommonDigest.h>
#import "pinyin.h"

@implementation ConvertMethods

+ (CLLocationDistance) getDistanceFrom:(CLLocationCoordinate2D)startPoint to:(CLLocationCoordinate2D)endPoint {
    MKMapPoint point1 = MKMapPointForCoordinate(startPoint);
    MKMapPoint point2 = MKMapPointForCoordinate(endPoint);
    return MKMetersBetweenMapPoints(point1,point2);
}

+ (NSDate *) stringToDate:(NSString *)string withFormat:(NSString *)format withTimeZone:(NSTimeZone *)zone {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format]; //@"HH:mm:ss"
    [dateFormatter setTimeZone:zone];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}


+ (NSString *)getCurrentDataWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)getCuttentData
{
    return [ConvertMethods getCurrentDataWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *) dateToString:(NSDate *)date withFormat:(NSString *)format withTimeZone:(NSTimeZone *)zone {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:zone];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *) timeIntervalToString:(long long)interval withFormat:(NSString *)format withTimeZone:(NSTimeZone *)zone
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    [dateFormatter setTimeZone:zone];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (UIImage*) createImageWithColor: (UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIColor *)RGBColor:(int)rgb withAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:alpha];
}

+ (NSString *)generateQiniuImageUrl: (NSString *)url width:(int)w height:(int)h {
    //客户端不再对图片进行处理，显示的图片内容（尺寸等）完全有服务器来定夺。
//    return [NSString stringWithFormat:@"%@?imageView/1/w/%d/h/%d/q/80/format/jpg/interlace/1", url, 2*w, 2*h];
    return url;
}

+ (NSArray *)getMapPlatformInPhone
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://com.autonavi.amap"]]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"高德地图" forKey:@"platform"];
        [dic setObject:[NSNumber numberWithInteger:kAMap] forKey:@"type"];
        [retArray addObject:dic];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://com.baidu.map"]]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"百度地图" forKey:@"platform"];
        [dic setObject:[NSNumber numberWithInteger:kBaiduMap] forKey:@"type"];
        [retArray addObject:dic];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"苹果自带地图" forKey:@"platform"];
    [dic setObject:[NSNumber numberWithInteger:kAppleMap] forKey:@"type"];
    [retArray addObject:dic];
    return retArray;
}

+ (NSString *)sha1:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

#pragma mark - ********* 拼音转换 ***********
//将每个汉字的第一个拼音字母组装起来
+ (NSString *)chineseToPinyin:(NSString *)chinese
{
    NSLog(@"需要转换的汉字为：%@", chinese);
    if(![chinese isEqualToString:@""]){
        //join the pinYin
        NSString *pinYinResult = [NSString string];
        for(int j = 0;j < chinese.length; j++) {
            NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                             pinyinFirstLetter([chinese characterAtIndex:j])]uppercaseString];
            pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        NSLog(@"转换完成的字符为：%@", pinYinResult);
        return pinYinResult;
    } else {
        return @"";
    }
}
@end
