//
//  pushSettingModel.swift
//  drink
//
//  Created by user on 22/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import ObjectMapper

class pushSettingModel:Mappable{
    public var pushAuth:String?
    public var loginCheck:Bool?
    
    required init?(map: Map) {
    }//프로토콜 필수 구현조건
    
    func mapping(map: Map) {
        pushAuth <- map["pushAuth"]
        loginCheck <- map["loginCheck"]
    }//프로토콜 필수 구현조건
}
