//
//  notificationModel.swift
//  drink
//
//  Created by user on 03/09/2019.
//  Copyright © 2019 user. All rights reserved.
//

import ObjectMapper

class notificationModel:Mappable{

    public var to:String?
    public var notification:Notification = Notification()
    public var data:Data = Data()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
    
    class Notification:Mappable{
        
        public var title:String?
        public var text:String?
        public var sound:String?
        public var badge:Int?
        public var click_action:String?
        public var content_available:String?
        public var apns_push_type:String?//: “background”,
        public var apns_priority:String?//: 5
        
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
            sound <- map["sound"]
            badge <- map["badge"]
            content_available <- map["content_available"]
            apns_push_type <- map["apns_push_type"]
            apns_priority <- map["apns_priority"]
            click_action <- map["click_action"]
        }
    }
    
    class Data:Mappable{
        public var title:String?
        public var text:String?
        public var click_action:String?
        public var content_available:String?
        public var apns_push_type:String?
        public var apns_priority:String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
            click_action <- map["click_action"]
            content_available <- map["content_available"]
            apns_push_type <- map["apns_push_type"]
            apns_priority <- map["apns_priority"]
        }
    }
}
