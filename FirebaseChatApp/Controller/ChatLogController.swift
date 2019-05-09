//
//  ChatLogController.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 22.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ChatLogController: UICollectionViewController {
    
    var messageController: MessageController?
    var messages = [Message]()
    
    var targetUser: User? {
        didSet {
            
            if let user = targetUser {
                self.setupNavigationItemWithUser(user: user)
            }
            
            self.observeMessages()
        }
    }
    private let cellId = "cellId"
    
    var timer: Timer?
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "pick_image").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(r: 210, g: 210, b: 210)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendImageTap)))

        containerView.addSubview(imageView)
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextField)
        containerView.addSubview(topBorderView)
        
        imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        inputTextField.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        topBorderView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        topBorderView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        topBorderView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topBorderView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    @objc private func handleSendImageTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.backgroundColor = .clear
        textField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCollectionViewTapped)))
        
        setupObservers()
        
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    @objc func handleCollectionViewTapped() {
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationItemWithUser(user: User) {
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
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc fileprivate func handleKeyboardDidShow() {
        self.scrollToLastItem()
    }
    
    @objc func handleTextFieldChange() {
        guard let inputText = inputTextField.text else { return }
        sendButton.isEnabled = !inputText.isEmpty ? true : false
    }
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = targetUser?.uid else {
            return
        }
        
        Database.database().reference().child("user-messages").child(uid).child(toId).observe(.childAdded) { (snapshot1) in
            
            let messageId = snapshot1.key
            Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value, with: { (snapshot2) in
                
                guard let dictionary = snapshot2.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                message.id = snapshot2.key
                
                self.messages.append(message)
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.scrollToLastItem()
                    }
                })
                
            })
        }
    }
    
    fileprivate func scrollToLastItem() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func handleSend() {
        
        let message = inputTextField.text!
        let properties: [String: AnyObject] = ["text": message] as [String: AnyObject]
        
        handleSendMessageWithProperties(properties: properties)
        
    }
    
    fileprivate func handleSendMessageWithProperties(properties: [String: AnyObject]) {
        
        let senderId = (Auth.auth().currentUser?.uid)!
        let receiverId = (targetUser?.uid)!
        
        let timestamp = NSNumber(value: Date().timeIntervalSince1970)
        
        var values = ["sender": senderId, "receiver": receiverId, "timestamp": timestamp, "seen": false] as [String : Any]
        
        properties.forEach { (arg) in
            let (key, value) = arg
            values[key] = value
        }
        
        Database.database().reference().child("messages").childByAutoId().updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            let messageId = ref.key
            Database.database().reference().child("user-messages").child(senderId).child(receiverId).updateChildValues([messageId: 1])
            Database.database().reference().child("user-messages").child(receiverId).child(senderId).updateChildValues([messageId: 1])
            
            
            
            self.inputTextField.text = nil
            self.sendButton.isEnabled = false
        }
    }
    
    fileprivate func handleSendImageMessage(imageUrl: String, image: UIImage) {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let properties: [String: AnyObject] = ["imageUrl": imageUrl, "imageWidth": imageWidth, "imageHeight": imageHeight] as [String: AnyObject]
        
        self.handleSendMessageWithProperties(properties: properties)
    }
    
    fileprivate func uploadImageToFirebase(image: UIImage) {
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.2) else {
            return
        }
        
        let imageName = UUID().uuidString
        
        Storage.storage().reference().child("message_images").child("\(imageName).jpg").putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
                return
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            self.handleSendImageMessage(imageUrl: imageUrl, image: image)
        }
    }
}

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        }
        
        if selectedImage != nil {
            uploadImageToFirebase(image: selectedImage!)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let message = messages[indexPath.item]
        
        if !message.messageSeen() {
            
            guard let messageId = message.id else { return }
            
            updateMessageSeenWithId(messageId: messageId)
        }
        
    }
    
    fileprivate func updateMessageSeenWithId(messageId: String) {
        Database.database().reference().child("messages").child(messageId).updateChildValues(["seen": true], withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            self.messageController?.attemptGetMessageAndReload(messageId: messageId)
            
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCell
        let message = messages[indexPath.item]
        
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
        
    }
    
    func setupCell(cell: ChatLogCell, message: Message) {
        cell.messageTextView.text = message.text
        
        if let profileImageUrl = targetUser?.profileImageUrl {
            cell.profileImageView.loadImageFromCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.sender == Auth.auth().currentUser?.uid {
            cell.chatBubbleView.backgroundColor = ChatLogCell.blueColor
            cell.messageTextView.textColor = .white
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
        } else {
            cell.chatBubbleView.backgroundColor = UIColor(r: 235, g: 235, b: 235)
            cell.messageTextView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageText = message.text {
            cell.chatBubbleWidthAnchor?.constant = self.estimatedFrameForText(text: messageText).width + 20
            cell.messageImageView.isHidden = true
        } else if let imageUrl = message.imageUrl {
            cell.chatBubbleWidthAnchor?.constant = 200
            cell.messageImageView.loadImageFromCacheWithUrlString(urlString: imageUrl)
            cell.chatBubbleView.backgroundColor = .clear
            cell.messageImageView.isHidden = false
        }
        
    }
    
    func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}

