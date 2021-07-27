//
//  NoneImageCache.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/3/22.
//

import Foundation

///一个只能返回空结果的ImageCache空壳
internal struct NoneImageCache: ImageCache {

    func retrieveImage(for resource: ImageResource, completion: @escaping (Image?) -> Void) {
        completion(nil)
    }

    func contains(resource: ImageResource, completion: @escaping (Bool) -> Void) {
        completion(false)
    }

}
