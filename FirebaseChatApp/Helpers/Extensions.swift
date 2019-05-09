//
//  Extensions.swift
//  FirebaseChatApp
//
//  Created by Gokhan Demirer on 21.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageFromCacheWithUrlString(urlString: String) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                guard let downloadedImage = UIImage(data: data!) else { return }
                
                self.image = downloadedImage
                
                imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                
            }
            
        }).resume()
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
}
