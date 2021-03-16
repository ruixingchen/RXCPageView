//
// Created by ruixingchen on 2021/1/30.
//

import UIKit

public protocol ImagePageDataDelegate: AnyObject {

    func imagePageData(_ imagePageData: ImagePageData, downloadingThumbnail progress: Float)
    func imagePageData(_ imagePageData: ImagePageData, completeDownloadingThumbnail result: Result<Image, Error>)
    func imagePageData(_ imagePageData: ImagePageData, downloadingOriginal progress: Float)
    func imagePageData(_ imagePageData: ImagePageData, completeDownloadingOriginal result: Result<Image, Error>)
    func imagePageDataDidChangeImageLoadingState(imagePageData: ImagePageData)

}

///图片浏览器的页面数据, 由于图片的加载是在数据对象内部完成的,这个对象需要被持有,不可以每次用的时候临时生成
open class ImagePageData: PageData {

    open var cellIdentifier: String = "image_normal"

    ///占位图
    open var placeholder: Image?
    ///缩略图的资源
    open var thumbnailImageResource: ImageResource?
    //原图的资源
    open var originalImageResource: ImageResource
    ///高清图的资源, 一般无需使用
    //open var highQualityImageResource: ImageResource?

    ///图片的缓存管理对象
    open var imageCache: ImageCache?
    ///图片的下载器
    open var imageDownloader: ImageDownloader = CommonImageDwonloader.init()

    var thumbnailState: ImageLoadingState = .none {didSet {self.delegate?.imagePageDataDidChangeImageLoadingState(imagePageData: self)}}
    var originalState: ImageLoadingState = .none {didSet {self.delegate?.imagePageDataDidChangeImageLoadingState(imagePageData: self)}}

    ///是否自动加载原图, 0表示不自动加载, 1表示自动加载, 其他的数值可以自定义
    open var loadOriginalAutomatically: UInt8 = 0
    ///是否允许缩放
    open var zoomScaleEnabled: Bool = true

    open var shouldLoadOriginalAutomatically: Bool {return self.thumbnailImageResource == nil || self.loadOriginalAutomatically == 1}

    weak var delegate: ImagePageDataDelegate?

    public init(imageResource: ImageResource) {
        self.originalImageResource = imageResource
    }

    ///常见的初始化方式
    public convenience init(url: URL, thumbnail: URL) {
        let resource = ImageResource.init(url: url)
        self.init(imageResource: resource)
        self.thumbnailImageResource = ImageResource.init(url: thumbnail)
    }

    //MARK: - Query

    ///读取缩略图的缓存
    open func queryThumbnailImage(completion: @escaping (Image?)->Void) {
        guard let cache = self.imageCache, let resource = self.thumbnailImageResource else {
            completion(nil)
            return
        }
        cache.retrieveImage(for: resource, completion: completion)
    }

    ///读取原图的缓存
    open func queryOriginalImage(completion: @escaping (Image?)->Void) {
        guard let cache = self.imageCache else {
            completion(nil)
            return
        }
        cache.retrieveImage(for: self.originalImageResource, completion: completion)
    }

    //MARK: - Download

    ///下载缩略图, 同时通过代理通知下载进度和完成状态
    open func downloadThumbnailImage() {
        guard let resource = self.thumbnailImageResource else {return}
        guard self.thumbnailState < .downloading else {
            //如果此时正在下载中, 那么无需重新请求下载
            return
        }
        self.imageDownloader.download(with: resource) { (progress) in
            self.delegate?.imagePageData(self, downloadingThumbnail: progress)
        } completion: { (result) in
            self.delegate?.imagePageData(self, completeDownloadingThumbnail: result)
        }
    }

    ///下载原图, 同时通过代理通知下载进度和完成状态
    open func downloadOriginalImage() {
        guard self.originalState < .downloading else {return}
        self.imageDownloader.download(with: self.originalImageResource) { (progress) in
            self.delegate?.imagePageData(self, downloadingOriginal: progress)
        } completion: { (result) in
            self.delegate?.imagePageData(self, completeDownloadingOriginal: result)
        }
    }

}
