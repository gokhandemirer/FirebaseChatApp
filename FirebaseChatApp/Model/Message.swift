//
//  Message.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 22.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import Foundation
import FirebaseAuth

@objcMembers
class Message: NSObject {
    var id: String?
    var sender: String?
    var receiver: String?
    var text: String?
    var timestamp: NSNumber?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var seen: Bool?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        sender = dictionary["sender"] as? String
        receiver = dictionary["receiver"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        seen = dictionary["seen"] as? Bool
    }
    
    func messageSeen() -> Bool {
        return seen == false && sender != Auth.auth().currentUser?.uid ? false : true
    }
    
    func chatPartnerId() -> String? {
        return sender == Auth.auth().currentUser?.uid ? receiver : sender
    }
    
}
