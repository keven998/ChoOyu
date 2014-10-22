//
//  Constants.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/10.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

//友盟key
#define UMENG_KEY               @ "5433d2e2fd98c5b7a3020907"

//第三方分享相关key

#define SHARE_QQ_APPID          @ "1103275581"
#define SHARE_QQ_KEY            @ "VW1VnrywTEnK3vgw"
#define SHARE_SINA_KEY          @ "3743857858"
#define SHARE_RENREN_KEY        @ "5746d38353ed4bbb9bb4018bfb035a89"
#define SHARE_DOUBAN_KEY        @ "07402b7af9b58b7115c08270ed20a253"
#define SHARE_WEIXIN_APPID      @ "wx26b58c7173483529"
#define SHARE_WEIXIN_SECRET     @ "28daa05c021ebebe6d3cf06645b0c5ac"
#define SHARE_TECENTWEIBO_KEY   @ "801545095 "

#define WECHAT_API_DOMAIN       @ "https://api.weixin.qq.com/"

/***** API *****/

#define BASE_URL                @ "http://api.lvxingpai.cn/"

//用户相关接口
#define API_WEIXIN_LOGIN        (BASE_URL @"app/users/auth-signup")
#define API_USERINFO            (BASE_URL @"app/users/")
#define API_GET_CAPTCHA         (BASE_URL @"app/users/send-validation")
#define API_SIGNUP              (BASE_URL @"app/users/signup")        //用户注册
#define API_SIGNIN              (BASE_URL @"app/users/signin")
#define API_BINDTEL             (BASE_URL @"app/users/band-tel")      //绑定手机号


/***** Notification name *******/

#define weixinDidLoginNoti      @ "weixinDidLogin"              //微信登录完发送通知，传递 code 给服务器
#define userDidLoginNoti        @ "userDidLogin"                //用户完成所有登录工作。
#define userDidLogoutNoti       @ "userDidLogout"               //用户完成所有退出登录工作。
#define updateUserInfoNoti      @ "updateUserInfo"              //用户信息有更改。


/***** 登录注册时输入的错误码 *****/
typedef enum : NSUInteger {
    PhoneNumberError = 1,           //手机号号输入非法
    PasswordError,                  //密码输入非法
    PresentPasswordError,           //新密码输入非法
    ConfirmPasswordError,           //确认密码输入非法
    PasswordNotMatchedError,        //修改密码时两次输入的密码不一致
    IllegalCharacterError,          //包含非法字符
    InputEmptyError,                //输入字符为空
    NoError
    
} UserInfoInputError;

/***** 请求验证码和验证验证码时候向服务器发送的指令类型 *****/
typedef enum : NSUInteger {
    UserRegister = 1,        //用户注册时候进入时天下短信验证码
    UserBindTel,         //用户绑定手机
    UserLoseTel,         //用户忘记密码
} SMSType;

typedef enum : NSUInteger {
    ChangeName,
    ChangeSignature,
} UserInfoChangeType;

/***** 设备信息 *****/
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
























