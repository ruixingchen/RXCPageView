//
//  Image.swift
//  Example
//
//  Created by ruixingchen on 2021/2/1.
//

import UIKit

///描述了一个图片对象, 可以存储UIImage对象, 也可以存储自定义的图片数据
open class Image {

    open var image: UIImage?
    open var data: Data?
    open var object: Any?

    public init(image: UIImage) {
        self.image = image
    }

    public init(data: Data) {
        self.data = data
    }

    public init(object: Any) {
        self.object = object
    }

    public convenience init(image: UIImage?, data: Data?) {
        if let _image = image {
            self.init(image: _image)
            self.data = data
        }else if let _data = data {
            self.init(data: _data)
            self.image = image
        }else {
            fatalError("image 和 data 不能同时为空")
        }
    }

}
