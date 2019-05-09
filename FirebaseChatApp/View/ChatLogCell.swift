//
//  ChatLogCell.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 25.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

class ChatLogCell: UICollectionViewCell {
    
    static let blueColor = UIColor(r: 0, g: 152, b: 236)
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Dummy text..."
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let chatBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = ChatLogCell.blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "placeholder")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var chatBubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
        addSubview(chatBubbleView)
        addSubview(messageImageView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        bubbleViewRightAnchor = chatBubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = chatBubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        chatBubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chatBubbleWidthAnchor = chatBubbleView.widthAnchor.constraint(equalToConstant: 200)
        chatBubbleWidthAnchor?.isActive = true
        chatBubbleView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        messageImageView.leftAnchor.constraint(equalTo: chatBubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: chatBubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: chatBubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: chatBubbleView.heightAnchor).isActive = true
        
        messageTextView.leftAnchor.constraint(equalTo: chatBubbleView.leftAnchor, constant: 4).isActive = true
        messageTextView.topAnchor.constraint(equalTo: chatBubbleView.topAnchor).isActive = true
        messageTextView.widthAnchor.constraint(equalTo: chatBubbleView.widthAnchor).isActive = true
        messageTextView.bottomAnchor.constraint(equalTo: chatBubbleView.bottomAnchor).isActive = true
        
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
