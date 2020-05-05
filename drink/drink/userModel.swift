//
//  userModel.swift
//  drink
//
//  Created by user on 08/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

/*import UIKit

class userModel:NSObject{
    //var profileImageUrl:String?
    var uid:String?
    var location:Dictionary<String,Any>?
    var phonenumber:Int?
    var photoURL:String?
    var username:String?
    var sex:String?
}*/

import UIKit
import ObjectMapper
import GoogleMaps

class userModel:Mappable{
    public var age:String?
    public var body:String?
    public var personality:String?
    public var photo:Dictionary<String,Photo> = [:]
    public var sex:String?
    public var tall:String?
    public var username:String?
    //public var photoIndex:[String] = []
    public var blockList:Dictionary<String,Bool> = [:]
    public var blockedList:Dictionary<String,Bool> = [:]
    
    public var mainPhoto:Photo?
    //public var location:Dictionary<String,CLLocationDegrees> = [:]
    public var latitude:CLLocationDegrees?
    public var longitude:CLLocationDegrees?
    public var uid:String?
    public var pushtoken:String?
    public var heart:String?
    public var comment:String?
    public var platform:String?
    public var freeCoupon:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        age <- map["age"]
        body <- map["body"]
        personality <- map["personality"]
        photo <- map["photo"]
        sex <- map["sex"]
        tall <- map["tall"]
        username <- map["userName"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        blockList <- map["blockList"]
        blockedList <- map["blockedList"]
        heart <- map["heart"]
        //location <- map["location"]
        pushtoken <- map["pushToken"]
        comment <- map["comment"]
        platform <- map["platform"]
        freeCoupon <- map["freeCoupon"]
        /*username <- map["userName"]
        photo <- map["photo"]
        location <- map["location"]
        sex <- map["sex"]
        pushtoken <- map["pushToken"]*/
    }
    
    class Photo:Mappable{
        public var temp:String?
        public var tempHashCode:String?
        public var image:String?
        public var imageHashCode:String?
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            temp <- map["temp"]
            tempHashCode <- map["tempHashCode"]
            image <- map["image"]
            imageHashCode <- map["imageHashCode"]
        }
    }
    /*class location:Mappable{
        public var latitude:Int?
        public var longitude:Int?
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            latitude <- map["latitude"]
            longitude <- map["longitude"]
        }
        
    }*/
    
}
