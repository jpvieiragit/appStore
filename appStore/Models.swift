//
//  Models.swift
//  appStore
//
//  Created by _joelvieira on 24/11/2017.
//  Copyright © 2017 _joelvieira. All rights reserved.
//

import UIKit

class FeatureApps: NSObject {
    @objc var barnerCategory: AppCategory?
    @objc var appCategories: [AppCategory]?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "categories"{
            appCategories = [AppCategory]()
            
            for dict in value as! [[String: Any]] {
                let appCategory = AppCategory()
                appCategory.setValuesForKeys(dict)
                appCategories?.append(appCategory)
            }
            
        } else if key == "bannerCategory" {
            barnerCategory = AppCategory()
            barnerCategory?.setValuesForKeys(value as! [String: Any])
        } else {
            super.setValue(value, forKey: key)
        }
    }
}

class AppCategory: NSObject {
    @objc var type: String?
    @objc var name: String?
    @objc var apps: [App]?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "apps" {
            
            apps = [App]()
            for dict in value as! [[String: AnyObject]] {
                let app = App()
                app.setValuesForKeys(dict)
                apps?.append(app)
            }
            
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    static func fetchFeaturedApps(_ completionHandler: @escaping (FeatureApps) -> ()) {
        
        let urlString = "https://api.letsbuildthatapp.com/appstore/featured"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            
            do {
                
                let json = try(JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary)
                
                let featureApps = FeatureApps()
                featureApps.setValuesForKeys(json as! [String: Any])
                
//                var appCategories = [AppCategory]()
//
//                for dict in json["categories"] as! [[String: Any]] {
//                    let appCategory = AppCategory()
//                    appCategory.setValuesForKeys(dict)
//                    appCategories.append(appCategory)
//                }

                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler(featureApps)
                })
                
            } catch let err as NSError {
                print("Erro ao ler JSON \(err)")
            }
                        
        }) .resume()
                    
    }
    
    static func simpleAppCategories() -> [AppCategory] {
        let bestNewAppCategory = AppCategory()
        bestNewAppCategory.name = "Best New Apps"
        
        var apps = [App]()
        
        let frozenApp = App()
        frozenApp.name = "Disney Build It: Frozen"
        frozenApp.category = "Entertainment"
        frozenApp.imageName = "frozen"
        frozenApp.price = NSNumber(value: 1.99)
        apps.append(frozenApp)
        
        bestNewAppCategory.apps = apps
        
        let bestNewGamesCategory = AppCategory()
        bestNewGamesCategory.name = "Best New Games"
        
        var bestNewGamesApps = [App]()
        
        let telepaintApp = App()
        telepaintApp.name = "Telepaint"
        telepaintApp.category = "Games"
        telepaintApp.imageName = "telepaint"
        telepaintApp.price = NSNumber(value: 2.99)
        bestNewGamesApps.append(telepaintApp)
        
        bestNewGamesCategory.apps = bestNewGamesApps
        
        return[bestNewAppCategory, bestNewGamesCategory, ]
    }
}

class App: NSObject {
    @objc var id: NSNumber?
    @objc var name: String?
    @objc var category: String?
    @objc var imageName: String?
    @objc var price: NSNumber?
    
    @objc var screenshots: [String]?
    @objc var desc: String?
    @objc var appInformation: AnyObject?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "description" {
            self.desc = value as? String
        } else {
            super.setValue(value, forKey: key)
        }
    }
}
