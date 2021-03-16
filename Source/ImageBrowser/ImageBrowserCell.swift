//
// Created by ruixingchen on 2021/1/30.
//

import UIKit

///Cell的代理, 实现者默认是ImageBrowser实例
public protocol ImageBrowserCellDelegate: AnyObject {

    func imageBrowserCellDidSingleTap(_ cell: ImageBrowserCell)
    func imageBrowserCellDidLongPress(_ cell: ImageBrowserCell, gestureRecognizer: UILongPressGestureRecognizer)
    ///图片加载状态发生变化
    func imageBrowserCellDidChangeLoadingState(_ cell: ImageBrowserCell)
}

///用于显示单张图片的Cell
open class ImageBrowserCell: UICollectionViewCell, PageViewCell, UIScrollViewDelegate, ImagePageDataDelegate {

    ///用于缩放的ScrollView
    open var scrollView: UIScrollView = UIScrollView.init()
    ///显示图片的View, 子类可以自定义一个View来替换默认的UIImageView
    open lazy var imageContentView: UIView = self.initImageContentView()
    ///进度View
    open lazy var progressView: ProgressViewProtocol? = self.initProgressView()

    ///Cell的代理
    open weak var delegate: ImageBrowserCellDelegate?
    ///弱引用一份浏览器主体的指针
    open weak var browser: ImageBrowser?

    ///自定义的数据绑定closure
    //open var bindClosure:((ImageBrowserCell, PageData, Int)->Void)?

    ///使用一个ID来标记当前加载图片的任务, 防止在复用机制下由于任务完成时间不一致导致旧图覆盖新图的问题
    private var loadImageTaskID: UUID?
    ///记录上一次布局时候的bounds, 当要求进行布局但是bounds未发生变化的时候, 则不用重新布局, 防止因为CollectionView的布局机制导致画面突变
    open var lastLayoutBounds: CGRect = CGRect.zero
    ///图片的大小
    open var imageSize: CGSize = CGSize.init(width: 10, height: 10)

    ///最大的放大倍率, 默认3.0
    open var maximumZoomScale: CGFloat = 3.0 {didSet {self.scrollView.maximumZoomScale = self.maximumZoomScale}}
    ///使用双击的时候的放大倍率
    open var doubleTapZoomScale: CGFloat = 2.0

    open lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(self.didTriggerLongPress(sender:)))
    open lazy var singleTapGestureRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer.init(target: self, action: #selector(self.didTriggerSingleTap(sender:)))
        gr.require(toFail: self.doubleTapGestureRecognizer)
        return gr
    }()
    open lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer.init(target: self, action: #selector(self.didTriggerDoubleTap(sender:)))
        gr.numberOfTapsRequired = 2
        return gr
    }()
    open lazy var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.didTriggerPan(sender:)))

    ///持有绑定的数据
    open var bindedPageData: PageData?

    ///初始化一个显示图片的View, 子类可以重写来使用自定义View
    open func initImageContentView()->UIView {
        let view = UIImageView.init(frame: CGRect.zero)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }

    open func initProgressView()->ProgressViewProtocol? {
        let view = ProgressView.init()
        view.hideAutomatically = true
        view.onTaskFinish() //隐藏之
        return view
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetup()
    }

    open func initSetup() {
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = self.maximumZoomScale
        if #available(iOS 11, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        #if (debug || DEBUG)
        self.scrollView.showsVerticalScrollIndicator = true
        self.scrollView.showsHorizontalScrollIndicator = true
        #endif
        self.contentView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.imageContentView)
        if let view = self.progressView {
            //view.onTaskFinish()
            self.contentView.addSubview(view)
        }
        self.contentView.addGestureRecognizer(self.singleTapGestureRecognizer)
        self.contentView.addGestureRecognizer(self.longPressGestureRecognizer)
        self.contentView.addGestureRecognizer(self.doubleTapGestureRecognizer)
        //self.scrollView.addGestureRecognizer(self.panGestureRecognizer)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard self.bounds != self.lastLayoutBounds else {return}
        self.lastLayoutBounds = self.bounds
        self.resetZoomScale(animated: false)
        if self.scrollView.frame.size != self.contentView.bounds.size {
            self.scrollView.frame = self.contentView.bounds
        }
        self.resetImageContentViewFrame()
        self.layoutProgressView()
    }

    open func layoutProgressView() {
        if let view = self.progressView {
            let size = view.intrinsicContentSize
            let x = self.contentView.bounds.midX - size.width/2
            let y = self.contentView.bounds.midY - size.height/2
            view.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.lastLayoutBounds = CGRect.zero
        self.bindedPageData = nil
        self.resetZoomScale(animated: false)
        (self.imageContentView as? UIImageView)?.image = nil
        (self.imageContentView as? UIImageView)?.animationImages = nil
        self.progressView?.onTaskFinish()
    }

    open func didEndDisplaying(at indexPath: IndexPath) {

    }

    open func bindImage(image: Image) {
        (self.imageContentView as? UIImageView)?.image = image.image
        self.imageSize = image.image?.size ?? CGSize.init(width: 10, height: 10)
        self.resetZoomScale(animated: false)
        self.lastLayoutBounds = CGRect.zero
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    open func bindPageData(_ pageData: PageData, at page: Int) {
        guard let imageData = pageData as? ImagePageData else {return}
        if let placeholder = imageData.placeholder {
            self.bindImage(image: placeholder)
        }
        self.bindedPageData = imageData
        imageData.delegate = self
        self.tryQueryImage(imageData: imageData)
    }

    private func tryQueryImage(imageData: ImagePageData) {
        PVLog.verbose("开始尝试读取缓存")
        //先尝试读取原图缓存
        imageData.originalState = .querying

        imageData.queryOriginalImage { (originalImage) in
            if let _image = originalImage {
                PVLog.verbose("成功读取原图缓存")
                imageData.originalState = .loaded
                self.bindImage(image: _image)
            }else {
                if imageData.shouldLoadOriginalAutomatically {
                    PVLog.verbose("未找到原图缓存, 自动下载原图")
                    self.downloadImage(imageData: imageData)
                }else {
                    PVLog.verbose("未找到原图缓存, 尝试读取缩略图缓存")
                    imageData.thumbnailState = .querying
                    imageData.queryThumbnailImage { (thumbnailImage) in
                        if let _image = thumbnailImage {
                            PVLog.verbose("成功读取缩略图缓存")
                            self.bindImage(image: _image)
                            imageData.thumbnailState = .loaded
                        }else {
                            PVLog.verbose("未找到缩略图缓存, 开始下载流程")
                            self.downloadImage(imageData: imageData)
                        }
                    }
                }

            }
        }
    }

    //开始下载图片
    open func downloadImage(imageData: ImagePageData) {
        //从缓存中读取完毕, 如果没有读取到缓存, 那么开始下载原图或者缩略图
        PVLog.verbose("开始下载流程")
        if imageData.shouldLoadOriginalAutomatically {
            PVLog.verbose("自动下载原图")
            imageData.downloadOriginalImage()
            imageData.originalState = .downloading
        }else {
            PVLog.verbose("开始下载缩略图")
            imageData.downloadThumbnailImage()
            imageData.thumbnailState = .downloading
        }
    }

    ///加载原图, 这个方法应该是用户点击查看原图按钮后手动调用的
    open func loadOriginalImage() {
        guard let imageData = self.bindedPageData as? ImagePageData, imageData.originalState < .downloading else {return}
        imageData.downloadOriginalImage()
        imageData.originalState = .downloading
    }

    //MARK: - Tool

    open func showPlaceholderIfNeeded(imageData: ImagePageData) {
        guard let imageData = self.bindedPageData as? ImagePageData else {return}
        guard imageData.originalState < .loaded && imageData.thumbnailState < .loaded else {return}
        if let image = imageData.placeholder {
            self.bindImage(image: image)
        }
    }

    open func resetZoomScale(animated: Bool) {
        self.scrollView.setZoomScale(1.0, animated: animated)
    }

    //MARK: - Layout

    open func resetImageContentViewFrame() {
        self.imageContentView.frame = Self.calculateImageViewFrame(scrollViewBounds: self.scrollView.frame, imageSize: self.imageSize)
        self.scrollView.contentSize = self.imageContentView.bounds.size
    }

    ///计算在1.0的放大倍率下,某个尺寸的图片的frame
    open class func calculateImageViewFrame(scrollViewBounds: CGRect, imageSize: CGSize)->CGRect {
        //先计算匹配的尺寸
        guard imageSize.width > 0 && imageSize.height > 0 else {return CGRect.init(x: scrollViewBounds.midX, y: scrollViewBounds.midY, width: 0, height: 0)}
        let containerSize = scrollViewBounds.size
        //这里暂时只考虑横向滑动的场景, 纵向滑动的场景暂不考虑
        //这里暂时也不考虑横竖的问题,一律以宽度作为约束
        let width = containerSize.width
        let height = width/(imageSize.width/imageSize.height)

        let y = max(0, scrollViewBounds.midY - height/2)
        let x = max(0, scrollViewBounds.midX - width/2)
        let frame = CGRect.init(x: x, y: y, width: width, height: height)
        return frame
    }

    ///计算1.0放大倍率下图片View的center的位置
    open func calculateImageViewCenter()->CGPoint {
        var x = self.scrollView.contentSize.width / 2
        var y = self.scrollView.contentSize.height / 2
        let offsetX = (bounds.width - scrollView.contentSize.width) / 2
        if offsetX > 0 {
            x += offsetX
        }
        let offsetY = (bounds.height - scrollView.contentSize.height) / 2
        if offsetY > 0 {
            y += offsetY
        }
        return CGPoint(x: x, y: y)
    }

    //MARK: - Action

    @objc open func didTriggerSingleTap(sender: Any?) {
        //默认单击后即dismiss, 子类可以重写后改变行为
        PVLog.verbose("触发点击手势")
        self.delegate?.imageBrowserCellDidSingleTap(self)
    }

    @objc open func didTriggerDoubleTap(sender: UITapGestureRecognizer) {
        PVLog.verbose("触发双击手势")
        //双击的时候在放大和预览之间切换
        if self.scrollView.zoomScale-1.0 > 0.001 {
            //重置缩放比例
            self.resetZoomScale(animated: true)
            return
        }
        guard (self.bindedPageData as? ImagePageData)?.zoomScaleEnabled ?? true else {return}
        
        //放大
        let anchor = sender.location(in: self.imageContentView)
        let scale = self.doubleTapZoomScale
        let width = self.scrollView.bounds.size.width / scale
        let height = self.scrollView.bounds.size.height / scale
        let x = anchor.x - (width / 2)
        let y = anchor.y - (height / 2)
        self.scrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
    }

    @objc func didTriggerLongPress(sender: UILongPressGestureRecognizer) {
        ///长按事件由子类实现
        PVLog.verbose("触发长按手势")
        self.delegate?.imageBrowserCellDidLongPress(self, gestureRecognizer: sender)
    }

    @objc func didTriggerPan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            //根据手指滑动的距离, 计算图片的缩放

            break
        default:
            break
        }
    }

    //MARK: - UIScrollViewDelegate

    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageContentView
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.imageContentView.center = self.calculateImageViewCenter()
    }

    //MARK: - ImagePageDataDelegate

    open func imagePageData(_ imagePageData: ImagePageData, downloadingThumbnail progress: Float) {
        guard let binded = self.bindedPageData as? ImagePageData else {return}
        guard binded === imagePageData else {return}
        //当接收到缩略图下载进度的时候, 显进度条
        self.progressView?.onTaskProgress(progress)
    }

    open func imagePageData(_ imagePageData: ImagePageData, completeDownloadingThumbnail result: Result<Image, Error>) {
        guard let binded = self.bindedPageData as? ImagePageData else {return}
        guard binded === imagePageData else {return}
        PVLog.verbose("下载缩略图完成")
        switch result {
        case .failure(let error):
            //缩略图下载失败
            imagePageData.thumbnailState = .failed
            self.delegate?.imageBrowserCellDidChangeLoadingState(self)
            //显示加载失败的Toast
        case .success(let image):
            //缩略图下载成功
            if imagePageData.originalState != .downloading {
                self.progressView?.onTaskFinish()
            }
            guard imagePageData.originalState < .loaded else {
                //原图已经加载, 无需加载缩略图了
                return
            }
            self.bindImage(image: image)
        }

    }

    open func imagePageData(_ imagePageData: ImagePageData, downloadingOriginal progress: Float) {
        guard let binded = self.bindedPageData as? ImagePageData else {return}
        guard binded === imagePageData else {return}
        self.progressView?.onTaskProgress(progress)
    }

    open func imagePageData(_ imagePageData: ImagePageData, completeDownloadingOriginal result: Result<Image, Error>) {
        guard let binded = self.bindedPageData as? ImagePageData else {return}
        guard binded === imagePageData else {return}
        self.progressView?.onTaskFinish()
        PVLog.verbose("下载原图完成")
        switch result {
        case .failure(let error):
            imagePageData.originalState = .failed
        case .success(let image):
            imagePageData.originalState = .loaded
            self.bindImage(image: image)
        }

    }

    open func imagePageDataDidChangeImageLoadingState(imagePageData: ImagePageData) {
        self.delegate?.imageBrowserCellDidChangeLoadingState(self)
    }

}
