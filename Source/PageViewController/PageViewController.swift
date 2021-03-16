//
//  PageViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

open class PageViewController: UIViewController, PageViewDataSource, PageViewDelegate, TitlePageTabBarDelegate {

    open lazy var pageView: PageView = self.initPageView()
    open lazy var pageTabBar: PageTabBar? = self.initPageTabBar()

    public let initialPage: Int
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal

    open var viewControllers:[UIViewController] = []

    public init(viewControllers: [UIViewController], page: Int) {
        self.viewControllers = viewControllers
        self.initialPage = page
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func initPageView()->PageView {
        let pageView = PageView.init(page: self.initialPage, scrollDirection: self.scrollDirection)
        pageView.registerCell(cellClassOrNib: ViewControllerPageViewCell.self, identifier: "viewController")
        pageView.dataSource = self
        pageView.registerDelegate(self)
        return pageView
    }

    open func initPageTabBar()->PageTabBar? {
        let items = self.viewControllers.map({PageTabBarItem.init(title: $0.title)})
        let bar = TitlePageTabBar.init(items: items, cellStyle: nil)
        bar.layoutMode = .natural
        bar.delegate = self
        return bar
    }

    open override func loadView() {
        self.view = self.pageView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .all
        if #available(iOS 11, *) {} else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        if let bar = self.pageTabBar {
            self.view.addSubview(bar)
        }
        if let delegate = self.pageTabBar as? PageViewDelegate {
            self.pageView.registerDelegate(delegate)
        }
        if let receiver = self.pageTabBar as? PageViewScrollEventReceiver {
            self.pageView.registerScrollEventReceiver(receiver)
        }
        if let prefetching = self.pageTabBar as? PageViewDataSourcePrefetching {
            self.pageView.registerPrefetching(prefetching)
        }
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutPageTabBar()
    }

    open func layoutPageTabBar() {
        if let bar = self.pageTabBar {
            let size = bar.barSize(thatFits: self.view.bounds.size)
            let x = self.view.bounds.midX - size.width/2
            let y = self.view.bounds.minY + self.view.safeAreaInsets.top - self.additionalSafeAreaInsets.top
            bar.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
            var inset = self.additionalSafeAreaInsets
            inset.top = size.height
            if inset != self.additionalSafeAreaInsets {
                self.additionalSafeAreaInsets = inset
            }
        }
    }

    //MARK: - PageViewDataSource

    open func numberOfPages(in pageView: PageView) -> Int {
        return self.viewControllers.count
    }

    open func pageView(_ pageView: PageView, pageDataAt page: Int) -> PageData {
        let pageData = ViewControllerPageData.init(viewController: self.viewControllers[page])
        return pageData
    }

    //MARK: - PageViewDelegate

    open func pageView(_ pageView: PageView, didDequeuePageAt page: Int, cell: PageViewCell) {

    }

    open func pageView(_ pageView: PageView, willDisplayPageAt page: Int, cell: PageViewCell) {
        let vc = self.viewControllers[page]
        if vc.parent != self {
            self.addChild(vc)
            vc.didMove(toParent: self)
        }
    }

    open func pageView(_ pageView: PageView, didEndDsiplayingPageAt page: Int, cell: PageViewCell) {

    }

    open func pageViewDidReloadData(_ pageView: PageView) {

    }

    //MARK: - TitlePageTabBarDelegate

    open func titlePageTabBar(_ bar: TitlePageTabBar, didSelectPagAt page: Int) {
        //self.pageView.jump(to: page, animated: true)
        self.pageView.wormholeJump(to: page)
    }

}
