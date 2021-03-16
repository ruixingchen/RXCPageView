//
//  ImageBrowserFloatingViewManager.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/2.
//

import UIKit

///图片浏览器的悬浮View管理器, 默认实现了查看原图,页码数字, 分页指示器
open class ImageBrowserFloatingViewManager: PageViewFloatingViewManager, PageViewScrollEventReceiver, ImageBrowserDelegate {

    open var originalImageButton = UIButton.init(type: .system)
    open var pageLabel = UILabel()
    open var pageIndicator = UIPageControl.init()

    open weak var pageView: PageView?

    private var dragging: Bool = false

    public init() {
        self.pageLabel.textColor = UIColor.lightText
        self.pageLabel.textAlignment = .center
        self.pageIndicator.hidesForSinglePage = true
        self.pageIndicator.isUserInteractionEnabled = false
        self.originalImageButton.alpha = 0 //默认隐藏
        self.originalImageButton.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 12, bottom: 6, right: 12)
        self.originalImageButton.setTitle("原图", for: .normal)
        self.originalImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.originalImageButton.setTitleColor(UIColor.white, for: .normal)
        self.originalImageButton.layer.cornerRadius = 4
        self.originalImageButton.backgroundColor = UIColor.gray.withAlphaComponent(0.68)
        self.originalImageButton.addTarget(self, action: #selector(self.didTapOriginalImageButton), for: .touchUpInside)
    }

    open func addSubviews(to pageView: PageView) {
        pageView.addSubview(self.originalImageButton)
        pageView.addSubview(self.pageLabel)
        pageView.addSubview(self.pageIndicator)
    }

    open func layoutSubviews(in pageView: PageView) {
        var pointer: CGFloat = pageView.bounds.maxY - pageView.safeAreaInsets.bottom
        if !self.pageIndicator.isHidden {
            let size = self.pageIndicator.size(forNumberOfPages: self.pageIndicator.numberOfPages)
            let x = pageView.bounds.midX - size.width/2
            let y = pointer - 44
            self.pageIndicator.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
            pointer = self.pageIndicator.frame.minY
        }
        if true {
            ///注意这里在Xcode12.4下使用尺寸计算会导致PageView瞬间变化,可能是编译器或者系统的问题,暂时使用固定的尺寸代替
            let size = CGSize.init(width: 200, height: 24)
            let x: CGFloat = pageView.bounds.midX - size.width/2
            let y: CGFloat = pointer - 24
            let _frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
            self.pageLabel.frame = _frame
        }
        if true {
            let size = self.originalImageButton.intrinsicContentSize
            let x = pageView.bounds.minX + pageView.safeAreaInsets.left + 44
            let y = self.pageLabel.frame.minY - size.height
            self.originalImageButton.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
        }
    }

    ///根据当前页面的情况刷新悬浮层的显示
    open func refreshDisplaying() {
        guard let pageView = self.pageView else {return}
        guard let page = pageView.maxWidthPage else {return}
        let numberOfPages = pageView.numberOfPages
        self.pageLabel.text = "\(page.page+1)/\(numberOfPages)"
        self.pageIndicator.numberOfPages = numberOfPages
        self.pageIndicator.currentPage = page.page

        if self.dragging {
            self.originalImageButton.alpha = 0
        }else {
            self.updateOriginalButtonVisibility(animated: true)
        }
        //重新布局所有元素
        self.layoutSubviews(in: pageView)
    }

    //MARK: - PageViewDelegate

    public func pageView(_ pageView: PageView, didDequeuePageAt page: Int, cell: PageViewCell) {
        self.pageView = pageView
    }

    public func pageView(_ pageView: PageView, willDisplayPageAt page: Int, cell: PageViewCell) {
        self.pageView = pageView
    }

    public func pageView(_ pageView: PageView, didEndDsiplayingPageAt page: Int, cell: PageViewCell) {
        self.pageView = pageView
    }

    public func pageViewDidReloadData(_ pageView: PageView) {
        self.pageView = pageView
        self.refreshDisplaying()
    }

    public func imageBrowser(_ browser: ImageBrowser, didChangeLoaidngStateAtPage page: Int, thumbnailState: ImageLoadingState, originalState: ImageLoadingState) {
        self.refreshDisplaying()
    }

    public func imageBrowser(_ browser: ImageBrowser, didSingleTapAt page: Int) {

    }

    public func imageBrowser(_ browser: ImageBrowser, didLongPressAt page: Int) {

    }

    //MARK: - PageViewScrollEventReceiver

    public func pageViewWillBeginDragging(_ pageView: PageView) {
        self.pageView = pageView
        self.dragging = true
        if self.originalImageButton.alpha > 0 {
            UIView.animate(withDuration: 0.25) {
                self.originalImageButton.alpha = 0
            }
        }
    }

    public func pageView(_ pageView: PageView, didScrollWith event: ScrollEvent) {
        self.pageView = pageView
        self.refreshDisplaying()
    }

    public func pageViewDidEndDragging(_ pageView: PageView, willDecelerate decelerate: Bool) {
        self.pageView = pageView
    }

    public func pageViewDidEndScrolling(_ pageView: PageView) {
        self.pageView = pageView
        self.dragging = false
        //当停止滚动的时候, 获取当前显示的页面数据,并根据原图的状态控制原图按钮的显示与隐藏
        self.updateOriginalButtonVisibility(animated: true)
    }

    //MARK: - Tool

    ///根据当前的状态
    open func updateOriginalButtonVisibility(animated: Bool) {

        let showClosure:(Bool, Bool)->Void = { (show, animated)->Void in
            let alpha: CGFloat = show ? 1 : 0
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.originalImageButton.alpha = alpha
                }
            }else {
                self.originalImageButton.alpha = alpha
            }
        }

        guard !self.dragging else {
            showClosure(false, true)
            return
        }

        //这里注意获取一下Cell, 如果获取不到Cell, 表示尚未初始化完成, 需要隐藏原图按钮
        //当浏览器准备好之后
        if let pageView = self.pageView, let page = self.pageView?.maxWidthPage, let _ = pageView.cell(at: page.page), let imageData = pageView.dataSource?.pageView(pageView, pageDataAt: page.page) as? ImagePageData {
            if imageData.originalState < .downloading {
                showClosure(true, animated)
            }else {
                showClosure(false, animated)
            }
        }else {
            showClosure(false, false)
        }

    }

    //MARK: - Action

    ///点击原图按钮
    @objc func didTapOriginalImageButton() {
        //点击原图按钮之后, 通知Cell加载原图
        guard let pageView = self.pageView else {return}
        guard let page = pageView.maxWidthPage else {return}
        guard let cell = pageView.cell(at: page.page) as? ImageBrowserCell else {return}
        cell.loadOriginalImage()
    }

}
