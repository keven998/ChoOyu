//
//  FrendRequestManager.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class FrendRequestManager: NSObject {
    
    var frendRequestList: Array<FrendRequest> = Array()
    
    func addFrendRequest(request: AnyObject) {
        if request.isKindOfClass(FrendRequest) {
            self.addFrendRequest(request as! FrendRequest)
            
        } else {
            let frendReuqest = FrendRequest(json: request)
            self.addFrendRequest(frendReuqest)
        }
    }
    
    func addFrendRequestList(request: FrendRequest) {
        for tempRequest in frendRequestList {
            if tempRequest.userId == (request).userId {
                return
            }
        }
        frendRequestList.append(request)
    }
    
    func removeFrendRequest(userId: Int) {
        frendRequestList.filter({$0.userId != userId}
        )
    }
    
    func changeStatus(userId: Int, status: TZFrendRequest) {
        frendRequestList.map({(var request) -> FrendRequest in
            if request.userId == userId {
                request.status = status 
            }
            return request
        })
    }
   
}
