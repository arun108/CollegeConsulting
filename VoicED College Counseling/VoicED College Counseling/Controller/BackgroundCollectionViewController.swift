//
//  BackgroundCollectionViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/24/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

class BackgroundCollectionViewController: UICollectionViewController {
    
    weak var BackgroundCollectionView: UICollectionView!
    let pictureArray = Constants.pictureArray
    
    weak var parentViewcontroller: ChatViewController?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set datasource and delegate as self
        BackgroundCollectionView.dataSource = self
        BackgroundCollectionView.delegate = self

        // Register cell classes
        self.BackgroundCollectionView.register(BackgroundCollectionCell.self, forCellWithReuseIdentifier: Constants.backgroundCollectionCell)
    }
    
    override func loadView() {
        super.loadView()

        let BackgroundCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        BackgroundCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(BackgroundCollectionView)
        NSLayoutConstraint.activate([
            BackgroundCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            BackgroundCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            BackgroundCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            BackgroundCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        self.BackgroundCollectionView = BackgroundCollectionView
    }
    
    
   override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()

       if let flowLayout = self.BackgroundCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
           flowLayout.itemSize = CGSize(width: self.BackgroundCollectionView.bounds.width, height: 250)
       }
   }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictureArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = BackgroundCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.backgroundCollectionCell, for: indexPath) as! BackgroundCollectionCell
        
        let imageview: UIImageView = UIImageView(frame: CGRect(x: (self.view.frame.width / 2) - 60, y: 5, width: 120, height: 240))
        imageview.backgroundColor = .blue
        let img : UIImage = UIImage(named: pictureArray[indexPath.row])!
        imageview.image = img
        imageview.contentMode = .scaleAspectFit
        cell.contentView.addSubview(imageview)
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parentViewcontroller?.imageName = pictureArray[indexPath.item]
        defaults.set(pictureArray[indexPath.item], forKey: Constants.chatBackgroundImage)
        _ = navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 130, height: 240)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}
