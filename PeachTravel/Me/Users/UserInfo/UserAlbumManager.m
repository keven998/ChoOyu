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

+ (void)uploadUserAlbumPhoto:(UIImage *)photo withPhotoDesc:(NSString *)desc progress:(void (^)(CGFloat))progressBlock completion:(void (^)(BOOL isSuccess, AlbumImageModel *albumImage))completionBlock
{
    [UserAlbumManager requestUploadTokeAndUploadPhoto:photo photoDesc:desc progress:^(CGFloat progress) {
        progressBlock(progress);
        
    } completion:^(BOOL isSuccess, AlbumImageModel *image) {
        completionBlock(isSuccess, image);
    }];
}

/**
 *  获取上传七牛服务器所需要的 token，key
 *
 *  @param image
 */
+ (void)requestUploadTokeAndUploadPhoto:(UIImage *)image photoDesc:(NSString *)desc progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL isSuccess, AlbumImageModel *image))completionBlock
{
    
    progressBlock(0.0);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
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
                
            } completion:^(BOOL isSuccess, AlbumImageModel *image) {
                completionBlock(isSuccess, image);
            }];
            
        } else {
            completionBlock(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO, nil);

    }];
}

/**
 *  将图片上传至七牛服务器
 *
 *  @param image       上传的图片
 *  @param uploadToken 上传的 token
 *  @param key         上传的 key
 */
+ (void)uploadPhotoToQINIUServer:(UIImage *)image withToken:(NSString *)uploadToken andKey:(NSString *)key progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL isSuccess, AlbumImageModel *image))completionBlock
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
                  if (resp) {
                      AlbumImageModel *image = [[AlbumImageModel alloc] init];
                      image.imageId = [resp objectForKey:@"id"];
                      image.imageUrl = [resp objectForKey:@"url"];
                      image.smallImageUrl = [resp objectForKey:@"urlSmall"];
                      image.imageDesc = [resp objectForKey:@"caption"];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          completionBlock(YES, image);
                      });
                  } else {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          completionBlock(NO, nil);
                      });
                  }
              } option:opt];
    
}


+ (void)asyncDelegateUserAlbumImage:(AlbumImageModel *)albumImage userId:(NSInteger)userId completion:(void (^)(BOOL, NSString *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", [AccountManager shareAccountManager].account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/albums/%@", API_USERS, (long)userId, albumImage.imageId];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES, nil);
            
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

/**
 *  异步加载用户相册
 *
 *  @param userId     用户Id
 *  @param completion 完成后回调
 *
 *  @return
 */
+ (void)asyncLoadUserAlbum:(NSInteger)userId completion:(void (^)(BOOL isSuccess, NSArray *albumList))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%ld/albums", API_USERS, userId];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];

            NSArray *albumArray = [responseObject objectForKey:@"result"];
            for (id album in albumArray) {
                [retArray addObject:[[AlbumImageModel alloc] initWithJson:album]];
            }
            
            completion(YES, retArray);
        } else {
            completion(NO,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO,nil);
    }];
}

+ (void)asyncUpdateUserAlbumCaption:(NSString *)caption withImageId:(NSString *)imageId completion:(void (^)(BOOL))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%ld/albums/%@", API_USERS, accountManager.account.userId, imageId];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safeSetObject:caption forKey:@"caption"];
    
    [manager PUT:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];

}


@end
