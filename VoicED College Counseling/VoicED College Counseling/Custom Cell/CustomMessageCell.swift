//
//  CustomMessageCell.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 9/19/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {
    
    let name = UILabel()
    let message = UILabel()
    let receiverView = UIView()
    let email = UILabel()
    let avatar = UIImageView()
    
    var leftOrRightBubble : String = ""
    
    var leadingMessageConstraint: NSLayoutConstraint!
    var trailingMessageConstraint: NSLayoutConstraint!
    var leadingNameConstraint: NSLayoutConstraint!
    var trailingNameConstraint: NSLayoutConstraint!
    var leadingAvatarConstraint: NSLayoutConstraint!
    var trailingAvatarConstraint: NSLayoutConstraint!
    
    var isIncoming: Bool! {
        didSet {
            receiverView.backgroundColor = isIncoming ? .yellow : .red
            message.textColor = isIncoming ? .red : .yellow
            name.textColor = isIncoming ? .lightText : .yellow
            
            leadingNameConstraint.isActive = isIncoming ? true : false
            trailingNameConstraint.isActive = isIncoming ? false : true
            leadingMessageConstraint.isActive = isIncoming ? true : false
            trailingMessageConstraint.isActive = isIncoming ? false : true
            leadingAvatarConstraint.isActive = isIncoming ? true : false
            trailingAvatarConstraint.isActive = isIncoming ? false : true
      }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        receiverView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(receiverView)
        addSubview(message)
        addSubview(name)
        addSubview(avatar)
        
        receiverView.layer.cornerRadius = 12
        
        name.translatesAutoresizingMaskIntoConstraints = false
        message.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        message.numberOfLines = 0
        
        let constraints = [
            avatar.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            avatar.heightAnchor.constraint(equalToConstant: 50),
            avatar.widthAnchor.constraint(equalToConstant: 50),
            
            name.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            name.heightAnchor.constraint(equalToConstant: 20),
            
            message.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10),
            message.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            message.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            receiverView.topAnchor.constraint(equalTo: message.topAnchor, constant: -10),
            receiverView.leadingAnchor.constraint(equalTo: message.leadingAnchor, constant: -20),
            receiverView.bottomAnchor.constraint(equalTo: message.bottomAnchor, constant: 10),
            receiverView.trailingAnchor.constraint(equalTo: message.trailingAnchor, constant: 20),
            ]
        NSLayoutConstraint.activate(constraints)
        
        leadingAvatarConstraint = avatar.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingAvatarConstraint = avatar.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        leadingNameConstraint = name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor)
        trailingNameConstraint = name.trailingAnchor.constraint(equalTo: avatar.leadingAnchor)
        
        leadingMessageConstraint = message.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 20)
        trailingMessageConstraint = message.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -20)
        
        receiverView.layoutIfNeeded()
        avatar.layoutIfNeeded()
        message.layoutIfNeeded()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

