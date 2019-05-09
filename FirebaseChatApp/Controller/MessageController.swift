//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 16.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessageController: UITableViewController {
    
    let cellId = "cellId"
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUser()
        }
        
    }
    
    func setupNavigationItemWithUser(user: User) {
        
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.backgroundColor = .red
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let profileImageUrl = user.profileImageUrl {
            imageView.loadImageFromCacheWithUrlString(urlString: profileImageUrl)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = user.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let partnerId = messages[indexPath.row].chatPartnerId() else {
            return
        }
        
        Database.database().reference().child("users").child(partnerId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.setValuesForKeys(dictionary)
            self.showChatLogControllerWithUser(user: user)
            
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.keepSynced(true)
        
        userMessagesRef.observe(.childAdded) { (snapshot) in
            
            let userId = snapshot.key
            self.fetchUserMessagesWithId(fromId: uid, toId: userId)
            
        }
    }
    
    func fetchUserMessagesWithId(fromId: String, toId: String) {
        
        Database.database().reference().child("user-messages").child(fromId).child(toId).observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            self.attemptGetMessageAndReload(messageId: messageId)
            
        })
    }
    
    func attemptGetMessageAndReload(messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.keepSynced(true)
        
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let message = Message(dictionary: dictionary)
                message.id = snapshot.key
                
                if let partnerId = message.chatPartnerId() {
                    self.messageDictionary[partnerId] = message
                    self.messages = Array(self.messageDictionary.values)
                    
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                    
                }
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
                
            }
            
        })
    }
    
    func showChatLogControllerWithUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.targetUser = user
        chatLogController.messageController = self
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc fileprivate func handleNewMessage() {
        let newMessageController = NewMessageController(style: .plain)
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavigationItemWithUser(user: user)
            }
        }
    }
    
    @objc fileprivate func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        
        present(loginController, animated: true, completion: nil)
    }

}

