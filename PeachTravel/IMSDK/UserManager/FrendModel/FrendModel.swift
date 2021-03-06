//
//  FrendModel.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

/**
好友类型
*/
@objc enum IMFrendType: Int {
    case Default = 0
    case Frend = 1
    case Expert = 2
    case Group = 8
    case DiscussionGroup = 256
    case Business = 16
    case GroupMember = 4
    case Frend_Expert = 3
    case Frend_GroupMember = 5
    case Frend_Business = 17
    case Expert_GroupMember = 6
    case Business_GroupMember = 20
    case Black_Default = 128
    case Black_Frend = 129
    case Black_Business = 144
    case Black_Expert = 130
    case Black_DiscussionGroup = 384
}

//类型的权重值
@objc enum IMFrendWeightType: Int {
    case Frend = 1
    case Expert = 2
    case Group = 8
    case Business = 16
    case Favorite = 32
    case BlackList = 128
    case DiscussionGroup = 256
}

class FrendModel: NSObject {
    var isBlacked: Bool = false
    var userId: Int = -1
    var nickName: String = ""
    var type: IMFrendType = .Default
    var avatar: String = ""
    var avatarSmall: String = ""
    var shortPY: String = ""
    var fullPY: String = ""
    var signature: String = ""
    var memo: String = ""
    var sex: NSString = "M"
    var extData: NSString = ""
    var residence: NSString = ""
    var level: Int = 0
    var birthday: NSString = ""
    var age: Int {
        let format = NSDateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        let date = format.dateFromString(birthday as String)
        let interval = date?.timeIntervalSinceNow
        return Int(-trunc((interval ?? 0)/(60*60*24)/365))
    }
    var travelStatus: NSString = ""
    var guideCount:Int = 0
    var localityCnt:Int = 0
    var rolesDescription: NSString {
        if FrendModel.typeIsCorrect(self.type, typeWeight: IMFrendWeightType.Expert) {
            return "达"
        }
        return ""
    }
    var travelNoteCount:Int = 0
    var footprintCityCount = 0
    var footprintCountryCount = 0
    var userAlbum: Array<AlbumImage> = Array()
    
    var constellation: String {
        get {
            return FrendModel.costellationDescWithBirthday(birthday as String)
        }
    }
    
    var footprintDescription :NSString {
        get {
            return "\(footprintCountryCount)国 \(footprintCityCount)城市"
        }
    }
    
    var tags: Array<String> = Array()

    init(json: NSDictionary) {
        
        println("\(json)")
        
        if let blacked = json.objectForKey("isBlocked") as? Bool {
            isBlacked = blacked
        }
        
        userId = json.objectForKey("userId") as! Int
        
        if let str =  json.objectForKey("nickName") as? String {
            nickName = str
            fullPY = ConvertMethods.chineseToPinyin(str)
        }
        
        if let str =  json.objectForKey("avatar") as? String {
            avatar = str
        }
        
        if let avatarSmallStr =  json.objectForKey("avatarSmall") as? String {
            avatarSmall = avatarSmallStr
        }
        
        if let sig = json.objectForKey("signature") as? String {
            signature = sig
        }
        if let memoStr =  json.objectForKey("memo") as? String {
            memo = memoStr
        }
        
        if let str =  json.objectForKey("gender") as? String {
            sex = str
        }


        if let str =  json.objectForKey("residence") as? String {
            residence = str
        }
    
        if let day =  json.objectForKey("birthday") as? String {
            birthday = day
        }
        
        if let value =  json.objectForKey("level") as? Int {
            level = value
        }
        
        if let str =  json.objectForKey("travelStatus") as? String {
            travelStatus = str
        }
        if let int =  json.objectForKey("guideCnt") as? Int {
            guideCount = int
        }
        
        // 游记数量
        if let int = json.objectForKey("travelNoteCnt") as? Int {
            travelNoteCount = int
        }
        
        // 增加个字段
        if let int = json.objectForKey("localityCnt") as? Int {
            localityCnt = int
        }
        
        // 增加个类型:如果是黑名单,将类型改变
        if isBlacked {
            type = IMFrendType.Black_Default
        }
        
        if let count = json.objectForKey("countryCnt") as? Int {
            footprintCountryCount = count
        }
        
        if let count = json.objectForKey("trackCnt") as? Int {
            footprintCityCount = count
        }
        
        if let roles = json.objectForKey("roles") as? NSArray {
            if let role = roles.firstObject as? String {
                if role == "expert" {
                    type = IMFrendType.Expert
                } 
            }
        }
        
        // 增加派派点评和标签两个字段
      
        
        if let tag = json.objectForKey("tags") as? NSArray {
            tags = tag as! Array<String>
        }
        
    }
    
    override init() {
        
    }
   
    /**
    frendtype 是不是包含传入的类型
    
    :param: frendType
    :param: typeWeight
    
    :returns:
    */
    class func typeIsCorrect(frendType: IMFrendType, typeWeight: IMFrendWeightType) -> Bool {
        if (frendType.rawValue & typeWeight.rawValue) == 0 {
            return false
        }
        return true
    }
    
    
    class func costellationDescWithBirthday(birthday: String?) -> String {
        var star = ""
        if let date = ConvertMethods.stringToDate(birthday, withFormat: "yyyy-MM-dd", withTimeZone: NSTimeZone.systemTimeZone()) {
            var components = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: date)
            var month = components.month
            var day = components.day
            if (month == 1 && day >= 20) || (month == 2 && day <= 18) {
                star = "水瓶座"
            }
            else if (month == 2 && day >= 19) || (month == 3 && day <= 20) {
                star = "双鱼座"
            }
            else if (month == 3 && day >= 21) || (month == 4 && day <= 19) {
                star = "白羊座"
            }
            else if (month == 4 && day >= 20) || (month == 5 && day <= 20) {
                star = "金牛座"
            }
            else if (month == 5 && day >= 21) || (month == 6 && day <= 21) {
                star = "双子座"
            }
            else if (month == 6 && day >= 22) || (month == 7 && day <= 22) {
                star = "巨蟹座"
            }
            else if (month == 7 && day >= 23) || (month == 8 && day <= 22) {
                star = "狮子座";
            }
            else if (month == 8 && day >= 23) || (month == 9 && day <= 22) {
                star = "处女座";
            }
            else if (month == 9 && day >= 23) || (month == 10 && day <= 22) {
                star = "天秤座";
            }
            else if (month == 10 && day >= 23) || (month == 11 && day <= 21) {
                star = "天蝎座";
            }
            else if (month == 11 && day >= 22) || (month == 12 && day <= 21) {
                star = "射手座";
            }
            else if (month == 12 && day >= 22) || (month == 1 && day <= 19) {
                star = "摩羯座";
            }
        }
        return star;
    }
    
    /// 获取星座的图片名字
    class func bigCostellationImageNameWithBirthday(birthday: String?) -> String {
        var star = "dashboard_03_icon_constellation0.png"
        if let date = ConvertMethods.stringToDate(birthday, withFormat: "yyyy-MM-dd", withTimeZone: NSTimeZone.systemTimeZone()) {
            var components = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: date)
            var month = components.month
            var day = components.day
            if (month == 1 && day >= 20) || (month == 2 && day <= 18) {
                star = "dashboard_03_icon_constellation11.png"
            }
            else if (month == 2 && day >= 19) || (month == 3 && day <= 20) {
                star = "dashboard_03_icon_constellation12.png"
            }
            else if (month == 3 && day >= 21) || (month == 4 && day <= 19) {
                star = "dashboard_03_icon_constellation1.png"
            }
            else if (month == 4 && day >= 20) || (month == 5 && day <= 20) {
                star = "dashboard_03_icon_constellation2.png"
            }
            else if (month == 5 && day >= 21) || (month == 6 && day <= 21) {
                star = "dashboard_03_icon_constellation3.png"
            }
            else if (month == 6 && day >= 22) || (month == 7 && day <= 22) {
                star = "dashboard_03_icon_constellation4.png"
            }
            else if (month == 7 && day >= 23) || (month == 8 && day <= 22) {
                star = "dashboard_03_icon_constellation5.png"
            }
            else if (month == 8 && day >= 23) || (month == 9 && day <= 22) {
                star = "dashboard_03_icon_constellation6.png"
            }
            else if (month == 9 && day >= 23) || (month == 10 && day <= 22) {
                star = "dashboard_03_icon_constellation7.png"
            }
            else if (month == 10 && day >= 23) || (month == 11 && day <= 21) {
                star = "dashboard_03_icon_constellation8.png"
            }
            else if (month == 11 && day >= 22) || (month == 12 && day <= 21) {
                star = "dashboard_03_icon_constellation9.png"
            }
            else if (month == 12 && day >= 22) || (month == 1 && day <= 19) {
                star = "dashboard_03_icon_constellation10.png"
            }
        }
        return star;
    }
    
    // 将达人列表的达人生日转换成达人星座
    class func smallCostellationImageNameWithBirthday(birthday: String?) -> String {
        var star = "master_icon_constellation0.png"
        if let date = ConvertMethods.stringToDate(birthday, withFormat: "yyyy-MM-dd", withTimeZone: NSTimeZone.systemTimeZone()) {
            var components = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: date)
            var month = components.month
            var day = components.day
            if (month == 1 && day >= 20) || (month == 2 && day <= 18) {
                star = "master_icon_constellation11.png"
            }
            else if (month == 2 && day >= 19) || (month == 3 && day <= 20) {
                star = "master_icon_constellation12.png"
            }
            else if (month == 3 && day >= 21) || (month == 4 && day <= 19) {
                star = "master_icon_constellation1.png"
            }
            else if (month == 4 && day >= 20) || (month == 5 && day <= 20) {
                star = "master_icon_constellation2.png"
            }
            else if (month == 5 && day >= 21) || (month == 6 && day <= 21) {
                star = "master_icon_constellation3.png"
            }
            else if (month == 6 && day >= 22) || (month == 7 && day <= 22) {
                star = "master_icon_constellation4.png"
            }
            else if (month == 7 && day >= 23) || (month == 8 && day <= 22) {
                star = "master_icon_constellation5.png"
            }
            else if (month == 8 && day >= 23) || (month == 9 && day <= 22) {
                star = "master_icon_constellation6.png"
            }
            else if (month == 9 && day >= 23) || (month == 10 && day <= 22) {
                star = "master_icon_constellation7.png"
            }
            else if (month == 10 && day >= 23) || (month == 11 && day <= 21) {
                star = "master_icon_constellation8.png"
            }
            else if (month == 11 && day >= 22) || (month == 12 && day <= 21) {
                star = "master_icon_constellation9.png"
            }
            else if (month == 12 && day >= 22) || (month == 1 && day <= 19) {
                star = "master_icon_constellation10.png"
            }
        }
        return star;
    }


}





































