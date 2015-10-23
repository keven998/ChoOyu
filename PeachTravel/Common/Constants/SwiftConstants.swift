//
//  SwiftConstants.swift
//  PeachTravel
//
//  Created by liangpengshuai on 10/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import Foundation

let APP_THEME_COLOR: UIColor            = SwiftConstants.UIColorFromRGB(0x99cc66, alpha:1)
let APP_PAGE_COLOR: UIColor             = SwiftConstants.UIColorFromRGB(0xf7faf7, alpha:1)
let APP_THEME_COLOR_HIGHLIGHT: UIColor  = SwiftConstants.UIColorFromRGB(0x99cc66, alpha:1)
let COLOR_CHECKED: UIColor              = SwiftConstants.UIColorFromRGB(0xfa5064, alpha:1)
let COLOR_ALERT: UIColor                = SwiftConstants.UIColorFromRGB(0xff9600, alpha:1)
let COLOR_ENTER: UIColor                = SwiftConstants.UIColorFromRGB(0x4bd228, alpha:1)
let COLOR_LINKED: UIColor               = SwiftConstants.UIColorFromRGB(0x469bff, alpha:1)
let COLOR_DISABLE: UIColor              = SwiftConstants.UIColorFromRGB(0xe2e2e2, alpha:1)

let COLOR_TEXT_I: UIColor               = SwiftConstants.UIColorFromRGB(0x323232, alpha:1)
let COLOR_TEXT_II: UIColor              = SwiftConstants.UIColorFromRGB(0x646464, alpha:1)
let COLOR_TEXT_III: UIColor             = SwiftConstants.UIColorFromRGB(0x969696, alpha:1)
let COLOR_TEXT_IV: UIColor              = SwiftConstants.UIColorFromRGB(0xc8c8c8, alpha:1)
let COLOR_TEXT_V: UIColor               = SwiftConstants.UIColorFromRGB(0xcdcdcd, alpha:1)


class SwiftConstants {
    
    class func UIColorFromRGB(rgb: Int, alpha: Float) -> UIColor {
        let red = CGFloat(Float(((rgb>>16) & 0xFF)) / 255.0)
        let green = CGFloat(Float(((rgb>>8) & 0xFF)) / 255.0)
        let blue = CGFloat(Float(((rgb>>0) & 0xFF)) / 255.0)
        let alpha = CGFloat(alpha)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
