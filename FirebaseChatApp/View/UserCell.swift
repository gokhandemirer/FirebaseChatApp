//
//  UserCell.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 24.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            self.detailTextLabel?.text = message?.text
            
            if message?.imageUrl != nil {
                self.detailTextLabel?.text = "Sent an image..."
            }
            
            if let seconds = message?.timestamp?.doubleValue {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                self.timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: seconds))
            }
            
            if message?.messageSeen() == false {
                self.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                self.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                self.timeLabel.font = UIFont.boldSystemFont(ofSize: 13)
            } else {
                self.textLabel?.font = UIFont.systemFont(ofSize: 18)
                self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
                self.timeLabel.font = UIFont.systemFont(ofSize: 13)
            }
            
            setupUsernameAndProfileImage()
            
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 26
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    func setupUsernameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            Database.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageFromCacheWithUrlString(urlString: profileImageUrl)
                    }
                    
                }
                
                
            })
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        separatorInset = .init(top: 0, left: 68, bottom: 0, right: 0)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 52).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
