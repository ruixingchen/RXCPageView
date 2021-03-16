//
//  ImageResource.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/30.
//

import UIKit
import Photos

///定义了一个图片资源
///图片可以从很多地方获取到, 使用Resource对象来抽象一个图片资源
public struct ImageResource {

    ///图片对象
    public var image: Image?
    ///本地硬盘上的图片
    public var localURL:URL?
    ///图库里面的图片
    public var asset: PHAsset?
    ///远程服务器图片
    public var url: URL?
    ///unrecognized object, but our smart developer can still load an image from this, are you?
    public var object: Any?

    ///存储已经加载的图片数据
    public var loadedImageCache: Any?

    public init(image: UIImage) {
        self.image = Image.init(image: image)
    }

    public init(localURL: URL) {
        self.localURL = localURL
    }

    public init(asset: PHAsset) {
        self.asset = asset
    }

    public init(url: URL) {
        self.url = url
    }

    public init(object: Any) {
        self.object = object
    }

}
