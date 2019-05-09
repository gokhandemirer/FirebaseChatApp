//
//  LoginController+Handler.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 22.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

extension LoginController {
    
    @objc internal func handleSelectProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc internal func handleLoginRegister() {
        
        setUserInteractionForLoginRegister(bool: false)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
        
    }
    
    internal func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        AuthService.login(email: email, password: password) { (user, error) in
            if error != nil {
                self.setUserInteractionForLoginRegister(bool: true)
                self.alert(title: "Alert", message: (error?.localizedDescription)!)
                return
            }
            
            self.setUserInteractionForLoginRegister(bool: true)
            
            self.messageController?.setupNavigationItemWithUser(user: user!)
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    internal func handleRegister() {
        
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let profileImage = profileImageView.image, let profileImageData = UIImageJPEGRepresentation(profileImage, 0.1) else { return }
        
        AuthService.register(name: name, email: email, password: password, profileImageData: profileImageData) { (user, error) in
            if error != nil {
                self.setUserInteractionForLoginRegister(bool: true)
                self.alert(title: "Alert", message: (error?.localizedDescription)!)
                return
            }
            
            if let createdUser = user as? User {
                self.messageController?.setupNavigationItemWithUser(user: createdUser)
            }
            
            self.setUserInteractionForLoginRegister(bool: true)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc internal func handleSegmentedControl() {
        let buttonTitle = segmentedControl.selectedSegmentIndex == 0 ? "Login" : "Register"
        let containerViewConstant: CGFloat = segmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        UIView.animate(withDuration: 0.25) {
            self.profileImageView.alpha = self.segmentedControl.selectedSegmentIndex == 0 ? 0 : 1
        }
        
        loginRegisterButton.setTitle(buttonTitle, for: .normal)
        
        inputsContainerView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = containerViewConstant
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            nameTextFieldHeightAnchor?.isActive = false
            nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalToConstant: 0)
            nameTextFieldHeightAnchor?.isActive = true
            
            emailTextFieldHeightAnchor?.isActive = false
            emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
            emailTextFieldHeightAnchor?.isActive = true
            
            passwordTextFieldHeightAnchor?.isActive = false
            passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
            passwordTextFieldHeightAnchor?.isActive = true
        } else {
            nameTextFieldHeightAnchor?.isActive = false
            nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
            nameTextFieldHeightAnchor?.isActive = true
            
            emailTextFieldHeightAnchor?.isActive = false
            emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
            emailTextFieldHeightAnchor?.isActive = true
            
            passwordTextFieldHeightAnchor?.isActive = false
            passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
            passwordTextFieldHeightAnchor?.isActive = true
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
    }
    
}
