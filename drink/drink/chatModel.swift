//
//  chatModel.swift
//  drink
//
//  Created by user on 08/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import ObjectMapper

class chatModel:Mappable{
    public var users:Dictionary<String,Bool> = [:]//대화에 참여한 사람들
    public var comments:Dictionary<String,Comment> = [:]
    public var roomid:String?
    
    required init?(map: Map) {
        
    }//프로토콜 필수 구현조건
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }//프로토콜 필수 구현조건
    
    public class Comment:Mappable{
        public var uid:String?
        public var message:String?
        public var timestamp:Int?
        //public var readUsers:Dictionary<String?,Bool> = [:]
        public var readUsers:String?
        
        public required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
            readUsers <- map["readUsers"]
        }
    }
    
}
