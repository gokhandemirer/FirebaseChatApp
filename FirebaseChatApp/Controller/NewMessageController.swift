//
//  NewMessageController.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 18.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewMessageController: UITableViewController {
    
    private let cellId = "cellId"
    var messageController: MessageController?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        
        fetchUsers()
    }
    
    func setupNavigationItem() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    fileprivate func fetchUsers() {
        
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                
                if user.uid! != Auth.auth().currentUser?.uid {
                    self.users.append(user)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }

        }
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            self.messageController?.showChatLogControllerWithUser(user: user)

        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.timeLabel.isHidden = true
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageFromCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}

