//
//  SDImageCache.swift
//  Example
//
//  Created by ruixingchen on 2021/2/2.
//

import UIKit
import SDWebImage
import RXCPageView

class SDImageCache: ImageCache {

    static let shared = SDImageCache()

    func contains(resource: ImageResource, completion: @escaping (Bool) -> Void) {
        let key = SDWebImageManager.shared.cacheKey(for: resource.url)
        SDWebImageManager.shared.imageCache.containsImage(forKey: key, cacheType: .all) { (cacheType) in
            switch cacheType {
            case .none:
                completion(false)
            default:
                completion(true)
            }
        }
    }

    func retrieveImage(for resource: ImageResource, completion: @escaping (Image?) -> Void) {
        let key = SDWebImageManager.shared.cacheKey(for: resource.url)
        SDWebImageManager.shared.imageCache.queryImage(forKey: key, options: [], context: nil, cacheType: .all) { (image, data, cacheType) in
            if let _image = image {
                completion(Image.init(image: _image, data: data))
            }else if let _data = data {
                completion(Image.init(image: image, data: _data))
            }else {
                completion(nil)
            }
        }
    }

}
