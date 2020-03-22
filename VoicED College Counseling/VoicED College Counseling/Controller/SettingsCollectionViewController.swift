//
//  SettingsCollectionViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/26/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

class SettingsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var AvatarCollectionView: UICollectionView!
    
    let inset: CGFloat = 10
    let cellsPerRow = 5
    let defaults = UserDefaults.standard
    let settingsArray = Constants.avatarArray
    
    weak var parentViewcontroller: SettingsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AvatarCollectionView?.contentInsetAdjustmentBehavior = .always
        AvatarCollectionView?.register(AvatarCollectionCell.self, forCellWithReuseIdentifier: Constants.avatarCell)
    }
    
    // MARK: - UICollectionViewDataSource
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsArray.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.avatarCell, for: indexPath) as! AvatarCollectionCell
        let imageview: UIImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))

        let img : UIImage = UIImage(named: settingsArray[indexPath.row])!
        imageview.image = img
        imageview.contentMode = .scaleAspectFit
        cell.contentView.addSubview(imageview)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nameOfAvatar = settingsArray[indexPath.item]
        parentViewcontroller?.avatarName = nameOfAvatar
        defaults.set(nameOfAvatar, forKey: Constants.avatarImage)
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.updateAvatarImage), object: nil, userInfo: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + 5 * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        AvatarCollectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}
