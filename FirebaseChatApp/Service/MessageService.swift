//
//  MessageService.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 22.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MessageService {
    static func sendMessage(senderId: String, receiverId: String, text: String, completion: @escaping (Error?) -> Void) {
        
        let timestamp = NSNumber(value: Date().timeIntervalSince1970)
        
        let dictionary = ["sender" : senderId, "receiver" : receiverId, "text" : text, "timestamp" : timestamp] as [String : Any]

        Database.database().reference().child("messages").childByAutoId().updateChildValues(dictionary) { (error, ref) in
            if error != nil {
                completion(error)
                return
            }
            
            completion(nil)
            
        }
        
    }
}
