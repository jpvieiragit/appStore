//
//  AppDetailController.swift
//  appStore
//
//  Created by _joelvieira on 25/11/2017.
//  Copyright © 2017 _joelvieira. All rights reserved.
//

import UIKit

class AppDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var app: App? {
        didSet {
            
            if app?.screenshots != nil {
                return 
            }
            
            if let id = app?.id {
                let urlString = "https://api.letsbuildthatapp.com/appstore/appdetail?id=\(id)"
                
                guard let url = URL(string: urlString) else {return}
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    do {
                        
                        guard let data = data else {return}
                        
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {return}
                        
                        let appDetail = App()
                        appDetail.setValuesForKeys(json)
                        
                        self.app = appDetail
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.collectionView?.reloadData()
                        })
                        
                    } catch let err as NSError {
                        print("Erro ao ler JSON \(err)")
                    }
                    
                }) .resume()
            }
        }
    }
    
    fileprivate let headerId = "headerId"
    fileprivate let cellId = "cellId"
    fileprivate let descriptionCellId = "descriptionCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(AppDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(AppDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 1 {
            
            let dummySize = CGSize(width: view.frame.width - 8 - 8, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let rect = descriptionAttributedText().boundingRect(with: dummySize, options: options, context: nil)
            
            return CGSize(width: view.frame.width, height: rect.height + 30)
        }
        
        return CGSize(width: view.frame.width, height: 170)
    }
    
    fileprivate func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Description\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.count)
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
        
        if let desc = app?.desc {
            attributedText.append(NSAttributedString(string: desc, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.darkGray]))
        }
        
        return attributedText
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! AppDetailDescriptionCell
            cell.textView.attributedText = descriptionAttributedText()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
        cell.app = app
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! AppDetailHeader
        header.app = app
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 170)
    }
}

class AppDetailDescriptionCell: BaseCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE DESCRIPTION"
        return tv
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textView)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: textView)
        addConstraintsWithFormat(format: "H:|-14-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat(format: "V:|-4-[v0]-4-[v1(1)]|", views: textView, dividerLineView)
        
    }
}

class AppDetailHeader: BaseCell {
    
    var app: App? {
        didSet {
            if let imageName = app?.imageName {
                imageView.image = UIImage(named: imageName)
            }
            
            nameLabel.text = app?.name
            
            if let price = app?.price?.stringValue {
                buyButton.setTitle("$\(price)", for: .normal)
            }
        }
    }
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Details", "Review", "Related"])
        sc.tintColor = UIColor.darkGray
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello App"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BUY", for: .normal)
        button.layer.borderColor = UIColor(red: 0, green: 129/255, blue: 250/255, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(segmentedControl)
        addSubview(nameLabel)
        addSubview(buyButton)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat(format: "H:|-14-[v0(100)]-8-[v1]", views: imageView, nameLabel)
        addConstraintsWithFormat(format: "V:|-14-[v0(100)]", views: imageView)
        
        addConstraintsWithFormat(format: "V:|-14-[v0(20)]", views: nameLabel)
        
        addConstraintsWithFormat(format: "H:|-40-[v0]-40-|", views: segmentedControl)
        addConstraintsWithFormat(format: "V:[v0(34)]-8-|", views: segmentedControl)
        
        addConstraintsWithFormat(format: "H:[v0(60)]-14-|", views: buyButton)
        addConstraintsWithFormat(format: "V:[v0(32)]-56-|", views: buyButton)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionay = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionay[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionay))
    }
}

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
    
}
