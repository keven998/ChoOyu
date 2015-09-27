//
//  ARGUMENTS.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/18.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#ifndef ARGUMENTS_h
#define ARGUMENTS_h

#define EMOJI_SQLITE_LOCK // define为关闭  ndef为开放


#define EMOJI_RANK 7
#define EMOJI_ROW 3
#define EMOJI_MARGIN 5
#define EMOJI_TOOLBAR_PERCENTAGE 0.2
#define CELLIDENTIFY @"EMOJICELLINDETIFY"
#define EMOJI_TOOLBAR_BTN_PERCENTAGE 1/6
#define EMOJI_TOOLBAR_BTN_INSET 6
#define EMOJI_SENDBTN_WIDTH 80
#define EMOJI_SENDBTN_MARGIN 6
#define EMOJI_EMOJI_FONTSIZE 32
#define APP_THEME_COLOR                 UIColorFromRGB(0x99cc66)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif /* ARGUMENTS_h */
