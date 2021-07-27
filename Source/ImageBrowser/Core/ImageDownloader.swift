//
// Created by ruixingchen on 2021/1/30.
//

import Foundation

///定义了一个图片下载器
public protocol ImageDownloader {

    func download(with resource: ImageResource, progress:@escaping(Float)->Void, completion:@escaping(Result<Image, Error>)->Void)

}
