//
//  ViewController.swift
//  appStore
//
//  Created by _joelvieira on 23/11/2017.
//  Copyright © 2017 _joelvieira. All rights reserved.
//

import UIKit

class FeaturedAppsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    fileprivate let largeCellId = "largeCellId"
    fileprivate let headerId = "headerId"
    
    var appCategories: [AppCategory]?
    var featureApps: FeatureApps?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Feature Apps"
                
        AppCategory.fetchFeaturedApps { (featureApps) -> () in
            self.featureApps = featureApps
            self.appCategories = featureApps.appCategories
            self.collectionView?.reloadData()
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(LargeCategoryCell.self, forCellWithReuseIdentifier: largeCellId)
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    func showAppDetailForApp(app: App) {
        let layout = UICollectionViewFlowLayout()
        let appDetailController = AppDetailController(collectionViewLayout: layout)
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellId, for: indexPath) as! LargeCategoryCell
            cell.appCategory = appCategories?[indexPath.item]
            cell.featuredAppsController = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        cell.appCategory = appCategories?[indexPath.item]
        cell.featuredAppsController = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = appCategories?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 2 {
            return CGSize(width: view.frame.width, height: 160)
        }
        return CGSize(width: view.frame.width, height: 230)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! Header
        header.appCategory = featureApps?.barnerCategory
        return header
    }
    
}

class Header: CategoryCell {
    let bannerCellId = "bannerCellId"
    
    override func setupViews() {
        appsCollectionView.delegate = self
        appsCollectionView.dataSource = self
        
        appsCollectionView.register(BannerCell.self, forCellWithReuseIdentifier: bannerCellId)
        
        addSubview(appsCollectionView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":appsCollectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":appsCollectionView]))
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellId, for: indexPath) as! AppCell
        cell.app = appCategory?.apps?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2 + 50, height: frame.height)
    }
    
    fileprivate class BannerCell: AppCell {
        fileprivate override func setupViews() {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
            imageView.layer.borderWidth = 0.5
            imageView.layer.cornerRadius = 0
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":imageView]))
        }
    }
}

class LargeCategoryCell: CategoryCell {
    
    fileprivate let largeCellId = "largeCellId"
    
    override func setupViews() {
        super.setupViews()
        appsCollectionView.register(LargeAppCell.self, forCellWithReuseIdentifier: largeCellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellId, for: indexPath) as! AppCell
        cell.app = appCategory?.apps?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: frame.height - 32)
    }
    
    fileprivate class LargeAppCell: AppCell {
        fileprivate override func setupViews() {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[v0]-14-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":imageView]))
        }
    }
    
}

