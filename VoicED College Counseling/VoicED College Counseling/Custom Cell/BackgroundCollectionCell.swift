//
//  BackgroundCollectionCell.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/24/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit

class BackgroundCollectionCell: UICollectionViewCell {
    
    let cellImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        cellImage.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(cellImage)
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            cellImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 5),
            cellImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant:  (self.frame.size.width / 2) - 60),
            cellImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant:  (self.frame.size.width / 2) - 60),
            cellImage.heightAnchor.constraint(equalToConstant: 250)
        ])
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("Interface Builder is not supported!")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError("Interface Builder is not supported!")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImage.image = nil
    }
}
