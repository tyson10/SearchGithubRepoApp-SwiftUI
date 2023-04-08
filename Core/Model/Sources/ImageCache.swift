//
//  ImageCache.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/18.
//

import UIKit

public final class ImageCache {
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    public func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    public func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}
