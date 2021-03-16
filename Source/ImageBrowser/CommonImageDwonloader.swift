//
//  URLSessionImageDwonloader.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/2.
//

import UIKit
import Photos

public struct CommonImageDwonloader: ImageDownloader {

    public func download(with resource: ImageResource, progress: @escaping (Float) -> Void, completion: @escaping (Result<Image, Error>) -> Void) {
        if let image = resource.image {
            completion(.success(image))
        }else if let url = resource.url {
            let request = URLRequest.init(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let _error = error {
                    completion(.failure(_error))
                    return
                }
                guard let _data = data, let image = UIImage.init(data: _data, scale: UIScreen.main.scale) else {
                    completion(.failure(MessageError.init(message: "convert image  faield")))
                    return
                }
                completion(.success(Image.init(image: image, data: _data)))
            }
            task.resume()
        }else if let url = resource.localURL {
            DispatchQueue.global().async {
                guard let data = try? Data.init(contentsOf: url), let image = UIImage.init(data: data, scale: UIScreen.main.scale) else {
                    DispatchQueue.main.async {
                        completion(.failure(MessageError.init(message: "failed read data")))
                    }
                    return
                }
                completion(.success(Image.init(image: image, data: data)))
            }
        }else if let asset = resource.asset {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize.init(width: 999999, height: 999999), contentMode: .default, options: nil) { (image, _) in
                DispatchQueue.main.async {
                    if let _image = image {
                        completion(.success(Image.init(image: _image, data: nil)))
                    }else {
                        completion(.failure(MessageError.init(message: "failed read image")))
                    }
                }
            }
        }else {
            completion(.failure(MessageError.init(message: "faield read image")))
        }
    }

}
