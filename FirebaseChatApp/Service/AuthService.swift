//
//  AuthService.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 16.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AuthService {
    
    static func login(email:String, password:String, completion: @escaping (User?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
            // next step fetch user info from database
            
            guard let uid = user?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let values = snapshot.value as? [String : Any] {
                    let loggedInUser = User()
                    loggedInUser.setValuesForKeys(values)
                    
                    completion(loggedInUser, nil)
                }
                
            })
            
        }
    }
    
    static func uploadProfileImage(profileImageData: Data, completion: @escaping (String?, Error?) -> Void) {
        let imageNameUID = UUID().uuidString
        
        Storage.storage().reference().child("media").child("\(imageNameUID).jpg").putData(profileImageData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let urlString = metadata?.downloadURL()?.absoluteString else { return }
            
            completion(urlString, nil)
            
        })
    }
    
    static func register(name:String, email:String, password: String, profileImageData: Data, completion: @escaping (Any?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                completion(nil, error)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            AuthService.uploadProfileImage(profileImageData: profileImageData, completion: { (urlString, error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                
                let values: [String : Any] = ["name": name, "email": email, "profileImageUrl": urlString!, "uid": uid, "timestamp": ServerValue.timestamp()]
                
                Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                        completion(nil, error)
                        return
                    }
                    
                    let createdUser = User()
                    createdUser.setValuesForKeys(values)
                    
                    completion(createdUser, nil)
                    
                })
                
                
            })
            
        }
    }
}
