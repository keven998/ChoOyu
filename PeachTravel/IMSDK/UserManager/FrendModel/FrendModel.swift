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
    case ChatTop_Frend = 65
    case ChatTop_Group = 72
    case ChatTop_DiscussionGroup = 320
    case Black_Frend = 129
    case Black_Business = 144
    case Black_Expert = 130
    case Block_Discussion = 768
}

//类型的权重值
@objc enum IMFrendWeightType: Int {
    case Frend = 1
    case Expert = 2
    case Group = 8
    case Business = 16
    case Favorite = 32
    case ConversationTop = 64
    case BlackList = 128
    case DiscussionGroup = 256
    case BlockMessage = 512

}

class FrendModel: NSObject {
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
    var travelStatus: NSString = ""
    var guideCount:Int = 0
    var rolesDescription: NSString {
        if FrendModel.typeIsCorrect(self.type, typeWeight: IMFrendWeightType.Expert) {
            return "达"
        }
        return ""
    }
    var footprints: Array<CityDestinationPoi> = Array()
    var footprintCountryCount = 0
    var userAlbum: Array<AlbumImage> = Array()
    
    var costellation: NSString {
        get {
            var star = ""
            if let date = ConvertMethods.stringToDate(self.birthday as String, withFormat: "yyyy-MM-dd", withTimeZone: NSTimeZone.systemTimeZone()) {
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
    }
    
    var footprintDescription :NSString {
        get {
            var count = 0
            
            return "\(footprintCountryCount)国 \(footprints)城市"
        }
    }

    init(json: NSDictionary) {
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
        
        if let roles = json.objectForKey("roles") as? NSArray {
            if let role = roles.firstObject as? String {
                if role == "expert" {
                    type = IMFrendType.Expert
                } 
            }
        }
        
        if let footprintArray = json.objectForKey("footprints") as? NSArray {
            for dic in footprintArray {
                self.footprints.append(CityDestinationPoi(json: dic))
            }
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
    
}





































