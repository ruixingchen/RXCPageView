//
//  ImageBrowserViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/3.
//

import UIKit

public protocol ImageBrowserViewControllerDelegate: AnyObject {

}

///一个对ImageBrowser的封装VC
open class ImageBrowserViewController: UIViewController, PageViewDataSourcePrefetching, UIViewControllerTransitioningDelegate, ImageBrowserDelegate, ZoomAnimatedTransitioningDelegate {

    open lazy var browser: ImageBrowser = self.initBrowser()

    public var imagePageDatas:[ImagePageData] {
        didSet {
            self.browser.reloadData()
        }
    }
    public let initialPage: Int

    weak var delegate: ImageBrowserViewControllerDelegate?

    //open lazy var animatedTransitioning: ZoomAnimatedTransitioning? = ZoomAnimatedTransitioning.init()

    open func initBrowser()->ImageBrowser {
        let browser = ImageBrowser.init(images: self.imagePageDatas, page: self.initialPage)
        let floating = ImageBrowserFloatingViewManager.init()
        browser.registerDelegate(floating)
        browser.registerScrollEventReceiver(floating)
        browser.floatingViewManagers.append(floating)
        browser.registerPrefetching(self)
        browser.registerDelegate(self)
        browser.prefetchEnabled = true
        browser.prefetchPages = 2
        return browser
    }

    public init(images:[ImagePageData], page: Int) {
        self.imagePageDatas = images
        self.initialPage = page
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        self.view = self.browser
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11, *) {} else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    //MARK: - PageViewDataSourcePrefetching

    //预加载的逻辑:
    //如果有原图缓存, 那么直接将原图缓存加入到内存中
    //如果有缩略图缓存, 那么将缩略图加载到内存
    //如果没有原图缓存, 那么查看是否需要自动下载原图, 如果需要自动下载, 那么直接下载原图

    open func pageView(_ pageView: PageView, prefetchPagesAt pages: [Int]) {
        for i in pages {
            let imageData = self.imagePageDatas[i]
            //先查看有无缓存
            if let cache = imageData.imageCache {
                //先尝试读取原图缓存
                cache.retrieveImage(for: imageData.originalImageResource) { (image) in
                    guard image == nil else {return}
                    //没有获取到原图的缓存, 查看是否自动下载原图
                    if imageData.shouldLoadOriginalAutomatically {
                        imageData.downloadOriginalImage()
                    }else {
                        imageData.downloadThumbnailImage()
                    }
                }
            }else {
                ///图片数据没有缓存功能, 直接开始下载
                if imageData.shouldLoadOriginalAutomatically {
                    imageData.downloadOriginalImage()
                }else {
                    imageData.downloadThumbnailImage()
                }
            }
        }
    }

    //MARK: - ImageBrowserDelegate

    open func imageBrowser(_ browser: ImageBrowser, didChangeLoaidngStateAtPage page: Int, thumbnailState: ImageLoadingState, originalState: ImageLoadingState) {

    }

    open func imageBrowser(_ browser: ImageBrowser, didSingleTapAt page: Int) {
        self.dismiss(animated: true, completion: nil)
    }

    open func imageBrowser(_ browser: ImageBrowser, didLongPressAt page: Int) {

    }

    open func pageView(_ pageView: PageView, didDequeuePageAt page: Int, cell: PageViewCell) {

    }

    open func pageView(_ pageView: PageView, willDisplayPageAt page: Int, cell: PageViewCell) {

    }

    open func pageView(_ pageView: PageView, didEndDsiplayingPageAt page: Int, cell: PageViewCell) {

    }

    open func pageViewDidReloadData(_ pageView: PageView) {

    }

    //MARK: - UIViewControllerTransitioningDelegate

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let AT = ZoomAnimatedTransitioning.init()
        AT.appearing = true
        AT.browserViewController = self
        AT.delegate = self
        return AT
    }

    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let AT = ZoomAnimatedTransitioning.init()
        AT.appearing = false
        AT.browserViewController = self
        AT.delegate = self
        return AT
    }

    //MARK: - ZoomAnimatedTransitioningDelegate

    public func animatedTransitioningProjectiveImage(for transitioning: AnimatedTransitioning, context: UIViewControllerContextTransitioning, appearing: Bool, completion: @escaping ((UIImage, CGRect)?) -> Void) {
        var page: Int?
        if appearing {
            page = self.initialPage
        }else if let _page = self.browser.maxWidthPage {
            page = _page.page
        }
        guard let _page = page else {
            completion(nil)
            return
        }
        guard let sourceView = (self.delegate as? ImageBrowserViewControllerZoomAnimationDelegate)?.imageBrowser(self, sourceViewForAnimatingAt: _page) else {
            completion(nil)
            return
        }
        let image = sourceView.snapshot()
        let rect = sourceView.convert(sourceView.bounds, to: context.containerView)
        completion((image, rect))
    }

    public func animatedTransitioningDestinationImage(for transitioning: AnimatedTransitioning, context: UIViewControllerContextTransitioning, appearing: Bool, completion: @escaping ((UIImage, CGRect)?) -> Void) {
        //获取目标图片和位置, 这里直接根据ImagePageData的数据进行计算
        var page: Int?
        if appearing {
            page = self.initialPage
        }else if let _page = self.browser.maxWidthPage {
            page = _page.page
        }
        guard let _page = page else {
            completion(nil)
            return
        }
        let imageData = self.imagePageDatas[_page]

        func onImageReaded(image: UIImage) {
            //开始计算图片的位置
            let rect = ImageBrowserCell.calculateImageViewFrame(scrollViewBounds: context.containerView.bounds, imageSize: image.size)
            completion((image, rect))
        }

        //尝试读取缓存
        imageData.queryOriginalImage { (image) in
            if let _image = image?.image {
                onImageReaded(image: _image)
            }else {
                imageData.queryThumbnailImage { (image) in
                    if let _image = image?.image {
                        onImageReaded(image: _image)
                    }else {
                        //没有读取到原图和缩略图的缓存
                        completion(nil)
                        return
                    }
                }
            }
        }
    }

}
