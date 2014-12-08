//
//  Constants.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/10.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUtils.h"
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

/***** 个推相关 key *****/

#define kGeTuiAppId           @"dajFCa9UMt7Ezo6kqOZ4C9"
#define kGeTuiAppKey          @"2aMWW4drb67bQFixAQ5cj"
#define kGeTuiAppSecret       @"BmkFKzmOqI7YSrQhYbhAn3"


/***** API *****/

#define BASE_URL                @ "http://api.taozilvxing.cn/taozi/"

//攻略相关接口

#define API_GET_RECOMMEND                       (BASE_URL @"recommend")     //获取首页推荐接口
#define API_GET_DESTINATIONS                    (BASE_URL @"destinations")     //获取目的地接口

#define API_GET_CITYDETAIL                      (BASE_URL @"geo/localities/")
#define API_GET_SPOT_DETAIL                     (BASE_URL @"poi/vs/")
#define API_GET_RESTAURANT_DETAIL               (BASE_URL @"poi/restaurant/")
#define API_GET_SHOPPING_DETAIL                 (BASE_URL @"poi/shopping/")

#define API_GET_RESTAURANTSLIST_CITY            (BASE_URL @"poi/restaurant/localities/")
#define API_GET_SHOPPINGLIST_CITY               (BASE_URL @"poi/shopping/localities/")
#define API_GET_SPOTLIST_CITY                   (BASE_URL @"poi/vs/localities/")
#define API_GET_HOTELLIST_CITY                  (BASE_URL @"poi/hotel/localities/")

#define API_CREATE_GUIDE                        (BASE_URL @"create-guide")    //制作攻略

#define API_SAVE_TRIP                           (BASE_URL @"guides")    //保存攻略
#define API_GET_GUIDELIST                       (BASE_URL @"guides")    //获取攻略列表
#define API_GET_GUIDE                           (BASE_URL @"guides/")    //获取攻略列表
#define API_DELETE_GUIDE                        (BASE_URL @"guides/")    //删除攻略列表
#define API_SAVE_TRIPINFO                       (BASE_URL @"guides/info/")    //保存攻略信息

#define API_GET_FAVORITES                       (BASE_URL @"misc/favorites")    //获取我的收藏列表






//用户相关接口
#define API_WEIXIN_LOGIN                (BASE_URL @"users/auth-signup")
#define API_USERINFO                    (BASE_URL @"users/")
#define API_GET_CAPTCHA                 (BASE_URL @"users/send-validation")    //接收验证码
#define API_VERIFY_CAPTCHA              (BASE_URL @"users/check-validation")   //验证验证码
#define API_RESET_PWD                   (BASE_URL @"users/reset-pwd")           //重新设置密码
#define API_SIGNUP                      (BASE_URL @"users/signup")        //用户注册
#define API_SIGNIN                      (BASE_URL @"users/signin")
#define API_BINDTEL                     (BASE_URL @"users/bind")        //绑定手机号
#define API_SEARCH_USER                 (BASE_URL @"users/search")      //搜索好友
#define API_SEARCH_USER                 (BASE_URL @"users/search")      //搜索好友
#define API_ADD_CONTACT                 (BASE_URL @"users/contacts")   //添加好友
#define API_DELETE_CONTACTS             (BASE_URL @"users/contacts")   //删除好友
#define API_GET_USERINFO_WITHEASEMOB    (BASE_URL @"users/easemob")   //传一个环信 id 数组，得到一个桃子用户信息数组

//IM相关接口
#define API_GET_CONTACTS                (BASE_URL @"users/contacts")   //获得联系人列表

//其他一些乱七八糟的接口
#define API_GET_COVER_STORIES           (BASE_URL @"misc/cover-stories")  //获得封面故事接口
#define API_POST_PHOTOIMAGE             (BASE_URL @"misc/put-policy/portrait")  //获得封面故事接口




/***** Notification name *******/

#define weixinDidLoginNoti              @ "weixinDidLogin"              //微信登录完发送通知，传递 code 给服务器
#define userDidLoginNoti                @ "userDidLogin"                //用户完成所有登录工作。
#define userDidResetPWDNoti             @ "userDidResetPWD"                //用户成功完成重设忘记密码的工作。

#define userDidRegistedNoti             @ "userDidRegisted"                //用户完成所有注册登录工作。
#define userDidLogoutNoti               @ "userDidLogout"               //用户完成所有退出登录工作。
#define updateUserInfoNoti              @ "updateUserInfo"              //用户信息有更改。
#define loadedAddressBookNoti           @ "loadedAddressBook"           //通讯录联系人加载完成。
#define regectLoadAddressBookNoti       @ "regectLoadAddressBook"       //用户拒绝读取通讯录
#define frendRequestListNeedUpdateNoti  @ "updateFrendRequestList"      //更新好友请求列表
#define contactListNeedUpdateNoti       @ "updatecontactList"           //更新好友列表
#define updateDestinationsSelectedNoti      @ "updatecontactList"           //更新好友请求列表

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

/***** 用户验证验证码时候的原因 *****/
typedef enum : NSUInteger {
    UserLosePassword = 1,       //忘记密码
    UserBindTel                 //绑定手机号的时候
} VerifyCaptchaType;

/***** 请求验证码和验证验证码时候向服务器发送的指令类型 *****/
#define    kUserRegister         @"1"        //用户注册时候进入时天下短信验证码
#define    kUserLosePassword     @"2"        //用户忘记密码
#define    kUserBindTel          @"3"         //用户绑定手机

typedef enum : NSUInteger {
    ChangeName,
    ChangeSignature,
    ChangeTel,
    ChangeGender,
    ChangeAvatar
} UserInfoChangeType;


/***** 桃子旅行自定义消息枚举信息****/
typedef enum : NSUInteger {
    TZChatNormalText = 0,                  //普通文字信息
    TZChatTypeStrategy = 1,         //游记
    TZChatTypeCity,                 //城市
    TZChatTypeSpot,                 //景点
    TZChatTypeTravelNote,           //游记
    TZChatTypeFood,                 //美食
    TZChatTypeShopping,             //购物
    TZChatTypeHotel,                //酒店
    
    TZTipsMsg    =  100             //自定义的提示信息， 如：我加入了旅行派群组
    
} TZChatType;

/***** 桃子旅行好友请求枚举信息****/
typedef enum : NSUInteger {
    TZFrendDefault = 0,      //未处理
    TZFrendAgree,            //同意
    TZFrendReject,          //拒绝
    
} TZFrendRequest;

/***** 桃子旅行自定义透传枚举信息 ****/
typedef enum : NSUInteger {
    CMDAddContact = 1,
    CMDAgreeAddContact,
    CMDDeleteContact
} TZCMDChatType;


/***** 设备信息 *****/


#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue]>=8)


#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define APP_PAGE_COLOR              UIColorFromRGB(0xf4f4f4)
#define APP_THEME_COLOR             UIColorFromRGB(0xee528c)
#define APP_THEME_COLOR_HIGHLIGHT   UIColorFromRGB(0xcc306a)
#define APP_DIVIDER_COLOR           UIColorFromRGB(0xdcdcdc)
#define TEXT_COLOR_TITLE            UIColorFromRGB(0x333333)
#define TEXT_COLOR_TITLE_SUBTITLE   UIColorFromRGB(0x797979)
#define TEXT_COLOR_TITLE_HINT       UIColorFromRGB(0x999999)


#define kWindowWidth   [UIApplication sharedApplication].keyWindow.frame.size.width

/*****应用启动时是否应该启动引导页******/
#define shouldSkipIntroduce [[NSUserDefaults standardUserDefaults] boolForKey:[[AppUtils alloc] init].appVersion]

#define kShouldShowIntroduceWhenFirstLaunch   YES

/*****Yahoo!天气对应的 code 列表******/
#define yahooWeatherCode @[ @"龙卷风",@"热带风暴", @"暴风",@"大雷雨",@"雷阵雨",@"雨夹雪",\
                                      @"雨夹雹",\
                                      @"雪夹雹",\
                                      @"冻雾雨",\
                                      @"细雨",\
                                      @"冻雨",\
                                      @"阵雨",\
                                      @"阵雨",\
                                      @"阵雪",\
                                      @"小阵雪",\
                                      @"高吹雪",\
                                      @"雪",\
                                      @"冰雹",\
                                      @"雨淞",\
                                      @"粉尘",\
                                      @"雾",\
                                      @"薄雾",\
                                      @"烟雾",\
                                      @"大风",\
                                      @"风",\
                                      @"冷",\
                                      @"阴",\
                                      @"多云",\
                                      @"多云",\
                                      @"局部多云",\
                                      @"局部多云",\
                                      @"晴",\
                                      @"晴",\
                                      @"转晴",\
                                      @"转晴",\
                                      @"雨夹冰雹",\
                                      @"热",\
                                      @"局部雷雨",\
                                      @"偶有雷雨",\
                                      @"偶有雷雨",\
                                      @"偶有阵雨",\
                                      @"大雪",\
                                      @"零星阵雪",\
                                      @"大雪",\
                                      @"局部多云",\
                                      @"雷阵雨",\
                                      @"阵雪",\
                                      @"局部雷阵雨",\
                                      @"水深火热"\
                                      ]




















