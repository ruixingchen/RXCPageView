//
// Created by ruixingchen on 2021/1/30.
//

import UIKit

///描述一个图片的缓存对象,可以直接从内存中获取图片数据
public protocol ImageCache {

    ///从内存缓存中获取图片
    func retrieveImage(for resource: ImageResource, completion:@escaping(Image?)->Void)

    ///是否包含对应资源的缓存
    func contains(resource: ImageResource, completion:@escaping(Bool)->Void)

}
