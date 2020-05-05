//
//  historyModel.swift
//  drink
//
//  Created by user on 22/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import ObjectMapper

class historyModel:Mappable{
    public var buys_change:String?
    public var buys_comment:String?
    public var buys_date:String?
    public var buys_id:String?
    public var current_heart:String?

    required init?(map: Map) {
    }//프로토콜 필수 구현조건
    
    func mapping(map: Map) {
        buys_change <- map["buys_change"]
        buys_comment <- map["buys_comment"]
        buys_date <- map["buys_date"]
        buys_id <- map["buys_id"]
        current_heart <- map["current_heart"]
    }//프로토콜 필수 구현조건
    
}
