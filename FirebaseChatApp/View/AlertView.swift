//
//  AlertView.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 31.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

enum AlertViewType {
    case success, alert
}

class AlertView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Not found a network connection"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var alertType: AlertViewType? {
        didSet {
            setBackgroundColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        switch alertType {
        case .success?:
            backgroundColor = UIColor(r: 75, g: 181, b: 167)
        case .alert?:
            backgroundColor = UIColor(r: 165, g: 0, b: 0)
        default:
            backgroundColor = UIColor(r: 165, g: 0, b: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
