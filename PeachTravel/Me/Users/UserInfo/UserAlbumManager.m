//
//  UserAlbumManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <QiniuSDK.h>

#import "UserAlbumManager.h"

@implementation UserAlbumManager

+ (void)uploadUserAlbumPhoto:(UIImage *)photo withPhotoDesc:(NSString *)desc progress:(void (^)(CGFloat))progressBlock completion:(void (^)(BOOL))completionBlock
{
    [UserAlbumManager requestUploadTokeAndUploadPhoto:photo photoDesc:desc progress:^(CGFloat progress) {
        progressBlock(progress);
        
    } completion:^(BOOL isSuccess) {
        completionBlock(isSuccess);
    }];
}

/**
 *  获取上传七牛服务器所需要的 token，key
 *
 *  @param image
 */
+ (void)requestUploadTokeAndUploadPhoto:(UIImage *)image photoDesc:(NSString *)desc progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL isSuccess))completionBlock
{
    
    progressBlock(0.0);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)[AccountManager shareAccountManager].account.userId] forHTTPHeaderField:@"UserId"];
    
    NSDictionary *params;
    if (desc) {
        params = @{@"caption": desc};
    }
    
    [manager GET:API_POST_PHOTOALBUM parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self uploadPhotoToQINIUServer:image withToken:[[responseObject objectForKey:@"result"] objectForKey:@"uploadToken"] andKey:[[responseObject objectForKey:@"result"] objectForKey:@"key"] progress:^(CGFloat progress) {
                progressBlock(progress);
                
            } completion:^(BOOL isSuccess) {
                completionBlock(isSuccess);
            }];
            
        } else {
            completionBlock(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO);

    }];
}

/**
 *  将图片上传至七牛服务器
 *
 *  @param image       上传的图片
 *  @param uploadToken 上传的 token
 *  @param key         上传的 key
 */
+ (void)uploadPhotoToQINIUServer:(UIImage *)image withToken:(NSString *)uploadToken andKey:(NSString *)key progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL isSuccess))completionBlock
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
    typedef void (^QNUpProgressHandler)(NSString *key, float percent);
    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"text/plain"
                                               progressHandler:^(NSString *key, float percent) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       progressBlock(percent);
                                                   });
                                                                  }
                                                        params:@{ @"x:foo":@"fooval" }
                                                      checkCrc:YES
                                            cancellationSignal:nil];
    
    [upManager putData:data key:key token:uploadToken
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      completionBlock(YES);
                  });

              } option:opt];
    
}

@end
