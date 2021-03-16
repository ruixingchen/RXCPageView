//
//  SDImageDownloader.swift
//  Example
//
//  Created by ruixingchen on 2021/2/1.
//

import UIKit
import SDWebImage

class SDImageDownloader: ImageDownloader {

    static let shared = SDImageDownloader()

    func download(with resource: ImageResource, progress: @escaping (Float) -> Void, completion: @escaping  (Result<Image, Error>) -> Void) {
        guard let url = resource.url else {
            completion(.failure(NSError.init(domain: "", code: 0, userInfo: nil)))
            return
        }
        SDWebImageManager.shared.loadImage(with: url, options: []) { (received, total, _) in
            let _progress = Float(received)/Float(total)
            progress(_progress)
        } completed: { (image, data, error, _, _, _) in
            if let _image = image {
                completion(.success(Image.init(image: _image, data: data)))
            }else if let _data = data {
                completion(.success(Image.init(image: nil, data: _data)))
            }else {
                completion(Result.failure(NSError.init(domain: "", code: 0, userInfo: nil)))
            }
        }
    }

}
