//
//  UserCommentManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/1/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "UserCommentManager.h"

@implementation UserCommentManager

+ (void)asyncMakeCommentWithGoodsId:(NSInteger)goodsId ratingValue:(float)value andContent:(NSString *)contents isAnonymous:(BOOL)anonymous completionBlock:(void (^)(BOOL isSuccess))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/comments", API_GOODS, goodsId];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param safeSetObject:contents forKey:@"contents"];
    [param safeSetObject:[NSNumber numberWithFloat:value] forKey:@"rating"];
    [param safeSetObject:[NSNumber numberWithBool:anonymous] forKey:@"anonymous"];

    [LXPNetworking POST:url parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO);
    }];
}

+ (void)asyncLoadGoodsCommentsWithGoodsId:(NSInteger)goodsId completionBlock:(void(^)(BOOL isSuccess, NSArray <GoodsCommentDetail *> *commentsList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/comments", API_GOODS, goodsId];
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *commentList = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in [responseObject objectForKey:@"result"]) {
                GoodsCommentDetail *comment = [[GoodsCommentDetail alloc] initWithJson:dict];
                [commentList addObject:comment];
            }
            completion(YES , commentList);
        } else {
            completion(NO , nil);

        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO , nil);

    }];
}

@end

