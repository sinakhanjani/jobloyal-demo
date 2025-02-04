//
//  UIImageViewExtention.swift
//  Master
//
//  Created by Sina khanjani on 12/11/1399 AP.
//

import UIKit

private let cache = NSCache<NSString, UIImage>()
private let queue = DispatchQueue.global(qos: .utility)

extension UIImageView {
    ///Cache Images in a UICollectionView Using NSCache in Swift 5
    func loadImage(from address: String?) {
        queue.async {
            guard let address = address else {
                return
            }
            guard let url = URL(string: address) else {
                return
            }
            
            if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async {
                    self.image = cachedImage
                }
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    cache.setObject(image, forKey: url.absoluteString as NSString)
                    self.image  = image
                }
            }
        }
    }
}
