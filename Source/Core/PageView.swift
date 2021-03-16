//
//  PageView.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///一个分页浏览器
///当前的设计目标是成为横向浏览和竖向浏览的分页模式的基类
open class PageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    open lazy var collectionView: UICollectionView = self.initCollectionView()

    public let scrollDirection: UICollectionView.ScrollDirection

    ///悬浮View管理器, 需要在PageView被添加到superView之前赋值, 之后赋值的无效
    ///这个属性暂时支持的不好, 不要使用
    internal var floatingViewManagers:[PageViewFloatingViewManager] = []

    open weak var dataSource: PageViewDataSource?
    
    internal let delegates:NSPointerArray = NSPointerArray.init(options: .weakMemory)
    internal let scrollEventReceivers:NSPointerArray = NSPointerArray.init(options: .weakMemory)
    internal let prefetchingDelegates:NSPointerArray = NSPointerArray.init(options: .weakMemory)

    private var alreadyMoveToSuperview: Bool = false
    private var lastVisiblePages:[PageAttributes] = []
    private let initialPage: Int
    private var lastLayoutBounds: CGRect = CGRect.zero

    private var collectionViewKVOContext: String? = ""

    ///返回当前可见的页面, 如果没有或者获取失败, 返回空数组
    open var visiblePages:[PageAttributes] {return self.calculateVisiblePages()}
    open var numberOfPages: Int {return self.collectionView.numberOfItems(inSection: 0)}
    ///返回当前可见的页面中宽度最大的那个
    open var maxWidthPage: PageAttributes? {return self.visiblePages.max(by: {
        switch self.scrollDirection {
        case .horizontal:
            return $0.visibleRect.width < $1.visibleRect.width
        case .vertical:
            return $0.visibleRect.height < $1.visibleRect.height
        @unknown default:
            return $0.visibleRect.width < $1.visibleRect.width
        }
    })}

    ///是否开启预加载功能(非CollectionView的prefetching)
    open var prefetchEnabled: Bool = true
    ///预加载多少页
    open var prefetchPages: Int = 2

    ///当前是否处于跳跃状态
    public private(set) var jumping: Bool = false

    ///虫洞跳跃时的临时数据源
    private var wormholeJumpDataSource:[Int: PageData] = [:]

    deinit {
        self.removeCollectionViewKVO()
    }

    open func initCollectionView()->UICollectionView {
        let flow = PageViewCollectionViewLayout.init()
        flow.scrollDirection = self.scrollDirection
        flow.sectionInset = UIEdgeInsets.zero
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.pageSpacing = 0
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flow)
        collectionView.isDirectionalLockEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        #if (debug || DEBUG)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = true
        #endif
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }

    public init(page: Int, scrollDirection: UICollectionView.ScrollDirection) {
        self.scrollDirection = scrollDirection
        self.initialPage = page
        super.init(frame: CGRect.zero)
        self.initSetup()
    }

    public required init?(coder: NSCoder) {
        self.scrollDirection = .horizontal
        self.initialPage = 0
        super.init(coder: coder)
    }

    open func initSetup() {
        self.collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new, .old], context: &self.collectionViewKVOContext)
        self.addSubview(self.collectionView)
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil && !self.alreadyMoveToSuperview {
            self.alreadyMoveToSuperview = true
            //首次被添加到superView
            self.floatingViewManagers.forEach({$0.addSubviews(to: self)})
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard self.bounds != self.lastLayoutBounds else {return}
        let sizeChanged = self.bounds.size != self.lastLayoutBounds.size
        self.lastLayoutBounds = self.bounds
        self.collectionView.frame = self.bounds
        //如果collectionView的尺寸发生了变化, 那么强制显示到最后显示的页码
        if sizeChanged {
            if let page = self.lastVisiblePages.max(by: { (lhs, rhs) -> Bool in
                switch self.scrollDirection {
                case .horizontal:
                    return lhs.visibleRect.width < rhs.visibleRect.width
                case .vertical:
                    return lhs.visibleRect.height < rhs.visibleRect.height
                @unknown default:
                    return lhs.visibleRect.width < rhs.visibleRect.width
                }
            })?.page {
                //布局完成之后, 强制滚动到上次显示的最宽的页面
                self.jump(to: page, animated: false)
            }
        }

        //通知悬浮View管理器进行布局
        self.floatingViewManagers.forEach({$0.layoutSubviews(in: self)})
    }

    ///register a cell to collectionView, should register all kind of cells before using
    open func registerCell(cellClassOrNib: Any, identifier: String) {
        if let cellClass = cellClassOrNib as? UICollectionViewCell.Type {
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }else if let nib = cellClassOrNib as? UINib {
            self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }else {
            fatalError("Only UICollectionViewCell.Type and UINib are supported")
        }
    }

    //MARK: - Delegates

    open func registerDelegate(_ delegate: PageViewDelegate) {
        self.delegates.add(delegate)
    }

    open func unregisterDelegate(_ delegate: AnyObject) {
        self.delegates.removeAll(where: {$0 === delegate})
    }

    internal func enumerateDelegates(closure:(PageViewDelegate)->Void) {
        self.delegates.forEach(closure: closure)
    }

    open func registerScrollEventReceiver(_ receiver: PageViewScrollEventReceiver) {
        self.scrollEventReceivers.add(receiver)
    }

    open func unregisterScrollEventReceiver(_ receiver: AnyObject) {
        self.scrollEventReceivers.removeAll(where: {$0 === receiver})
    }

    internal func enumerateScrollEventReceivers(closure:(PageViewScrollEventReceiver)->Void) {
        self.scrollEventReceivers.forEach(closure: closure)
    }

    open func registerPrefetching(_ prefetching: PageViewDataSourcePrefetching) {
        self.prefetchingDelegates.add(prefetching)
    }

    open func unregisterPrefetching(_ prefetching: AnyObject) {
        self.prefetchingDelegates.removeAll(where: {$0 === prefetching})
    }

    internal func enumeratePrefetching(closure:(PageViewDataSourcePrefetching)->Void) {
        self.prefetchingDelegates.forEach(closure: closure)
    }

    private var didReceiveContentOffsetChange: Bool = false

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var handled: Bool = false
        if object as? UICollectionView == self.collectionView, keyPath == #keyPath(UIScrollView.contentOffset), context == &self.collectionViewKVOContext {
            handled = true
            //当第一次接收到contentOffset发生变化的时候, 强制滚动到初始化页码
            if !self.didReceiveContentOffsetChange {
                self.didReceiveContentOffsetChange = true
                PVLog.verbose("接收到第一次contentOffset变化")
                self.removeCollectionViewKVO()
                ///滚动到初始化页数
                self.collectionView.scrollToItem(at: IndexPath.init(item: self.initialPage, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: false)
                self.scrollViewDidScroll(self.collectionView)
            }
        }
        if !handled {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    //MARK: - Misc

    private func removeCollectionViewKVO() {
        guard self.collectionViewKVOContext != nil else {return}
        self.collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &self.collectionViewKVOContext)
        self.collectionViewKVOContext = nil
    }

    //MARK: - Tool

    ///根据当前显示的页码通知代理进行预加载
    open func checkPrefetch() {
        guard self.prefetchEnabled else {return}
        //已经显示过的页面的数据可能已经被释放, 无论页面是否已经显示过, 我们都提前加载数据
        let currentVisiblePages = self.calculateVisiblePages()
        //确保可见页码发生了变化之后再预加载
        guard Set.init(currentVisiblePages.map({$0.page})) != Set.init(self.lastVisiblePages.map({$0.page})) else {return}
        let currentPageNums:[Int] = currentVisiblePages.map({$0.page})
        guard let max = currentPageNums.max(), let min = currentPageNums.min() else {return}
        var prefetchPages:[Int] = []
        prefetchPages.append(contentsOf: (min-self.prefetchPages..<min))
        prefetchPages.append(contentsOf: (max+1..<max+1+self.prefetchPages))
        prefetchPages = prefetchPages.filter({$0>=0 && $0<self.numberOfPages})
        self.enumeratePrefetching(closure: {$0.pageView(self, prefetchPagesAt: prefetchPages)})
    }

    ///计算当前条件下某一页的属性
    open func calculatePageAttributes(at page: Int)->PageAttributes? {
        guard let attributes = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath.init(item: page, section: 0)) else {return nil}
        let visibleRect: CGRect = attributes.frame.intersection(self.collectionView.bounds)
        let invisibleRect: CGRect
        switch self.scrollDirection {
        case .horizontal:
            let x = visibleRect.minX == 0 ? visibleRect.maxX : 0
            invisibleRect = CGRect.init(x: x, y: visibleRect.minY, width: attributes.frame.width-visibleRect.width, height: visibleRect.height)
        case .vertical:
            let y = visibleRect.minY == 0 ? visibleRect.maxY : 0
            invisibleRect = CGRect.init(x: visibleRect.minX, y: y, width: visibleRect.width, height: attributes.frame.height-visibleRect.height)
        @unknown default:
            //默认横向
            let x = visibleRect.minX == 0 ? visibleRect.maxX : 0
            invisibleRect = CGRect.init(x: x, y: visibleRect.minY, width: attributes.frame.width-visibleRect.width, height: visibleRect.height)
        }
        let page = PageAttributes.init(page: attributes.indexPath.item, visibleRect: visibleRect, invisibleRect: invisibleRect, frame: attributes.frame)
        return page
    }

    ///计算当前可见的页面
    open func calculateVisiblePages()->[PageAttributes] {
        var pages:[PageAttributes] = []
        let visibleAttributes:[UICollectionViewLayoutAttributes] = self.collectionView.collectionViewLayout.layoutAttributesForElements(in: self.collectionView.bounds) ?? []
        for i in visibleAttributes {
            if let page = self.calculatePageAttributes(at: i.indexPath.item) {
                pages.append(page)
            }
        }
        //从小到大排序
        pages = pages.filter({$0.visibleRect.width > 0 && $0.visibleRect.height > 0})
        pages = pages.sorted(by: {$0.page < $1.page})
        return pages
    }

    ///发送一个跳转到某一页的事件
    open func postScrollEventForJumping(to page: Int, animated: Bool) {
        //发送滚动事件
        guard let attributes = self.collectionView.layoutAttributesForItem(at: IndexPath.init(item: page, section: 0)) else {
            return
        }
        let visiblePages: [PageAttributes]
        switch self.scrollDirection {
        case .horizontal:
            visiblePages = [PageAttributes.init(page: page, visibleRect: attributes.frame, invisibleRect: CGRect.zero, frame: attributes.frame)]
        case .vertical:
            visiblePages = [PageAttributes.init(page: page, visibleRect: attributes.frame, invisibleRect: CGRect.zero, frame: attributes.frame)]
        @unknown default:
            visiblePages = [PageAttributes.init(page: page, visibleRect: attributes.frame, invisibleRect: CGRect.zero, frame: attributes.frame)]
        }
        let offset: CGPoint
        switch self.scrollDirection {
        case .horizontal:
            offset = CGPoint.init(x: attributes.frame.minX, y: 0)
        case .vertical:
            offset = CGPoint.init(x: 0, y: attributes.frame.minY)
        @unknown default:
            offset = CGPoint.init(x: attributes.frame.minX, y: 0)
        }
        let event = ScrollEvent.init(scrollDirection: self.scrollDirection, jump: true, animated: animated, contentOffset: offset, visiblePages: visiblePages, lastVisiblePages: self.lastVisiblePages)
        self.enumerateScrollEventReceivers(closure: {$0.pageView(self, didScrollWith: event)})
    }

    ///虫洞穿越到某一页
    open func wormholeJump(to page: Int) {
        guard let currentPage = self.maxWidthPage?.page else {return}
        guard page >= 0 && page < self.numberOfPages && page != currentPage else {return}
        //先获取当前页码, 如果虫洞穿越目标页和当前页距离过小, 那么直接执行普通跳跃即可
        guard Swift.abs(currentPage - page) >= 2 else {
            self.jump(to: page, animated: true)
            return
        }
        //先设置好全局属性
        self.jumping = true
        //发送滚动事件
        self.postScrollEventForJumping(to: page, animated: true)

        //第一步, 先直接跳跃到目标页的隔壁那一页
        //需要先设置好虫洞穿越用的临时数据源
        self.isUserInteractionEnabled = false
        let wormholePage: Int = page > currentPage ? page-1 : page+1
        self.wormholeJumpDataSource[wormholePage] = self.dataSource?.pageView(self, pageDataAt: currentPage)
        self.collectionView.scrollToItem(at: IndexPath.init(row: wormholePage, section: 0), at: [.centeredHorizontally, .centeredVertically], animated: false)
        //第二步, 滑动到目标页
        self.collectionView.scrollToItem(at: IndexPath.init(row: page, section: 0), at: [.centeredHorizontally, .centeredVertically], animated: true)
    }

    /// 跳跃到某一页, 这个方法只能连续滚动, 无法虫洞跳跃
    /// - Parameters:
    ///   - page: 目标页码
    open func jump(to page: Int, animated: Bool) {
        guard let currentPage = self.maxWidthPage else {return}
        guard page >= 0 && page < self.numberOfPages && page != currentPage.page else {return}
        //设置全局属性
        self.jumping = true
        if animated {
            self.isUserInteractionEnabled = false
        }
        //发送滚动事件
        self.postScrollEventForJumping(to: page, animated: animated)
        //滚动
        self.collectionView.scrollToItem(at: IndexPath.init(item: page, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: animated)
        if !animated {
            self.jumping = false
        }
    }

    ///重新加载数据
    open func reloadData() {
        self.collectionView.reloadData()
        self.enumerateDelegates(closure: {$0.pageViewDidReloadData(self)})
    }

    ///获取某一页的Cell对象
    open func cell(at page: Int)->PageViewCell? {
        return self.collectionView.cellForItem(at: IndexPath.init(item: page, section: 0)) as? PageViewCell
    }

    //MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPages(in: self) ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pageData = self.wormholeJumpDataSource[indexPath.item] ?? self.dataSource?.pageView(self, pageDataAt: indexPath.item) else {
            fatalError("需要先设置dataSource")
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pageData.cellIdentifier, for: indexPath) as? PageViewCell else {
            fatalError("cell 必须遵循 PageViewCell 协议")
        }
        self.delegates.forEach { (delegate: PageViewDelegate) in
            delegate.pageView(self, didDequeuePageAt: indexPath.item, cell: cell)
        }
        return cell
    }

    //MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _cell = cell as? PageViewCell {
            self.delegates.forEach { (delegate: PageViewDelegate) in
                delegate.pageView(self, willDisplayPageAt: indexPath.item, cell: _cell)
            }
            if let pageData = self.wormholeJumpDataSource[indexPath.item] ?? self.dataSource?.pageView(self, pageDataAt: indexPath.item) {
                _cell.bindPageData(pageData, at: indexPath.item)
            }
        }
    }

    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _cell = cell as? PageViewCell {
            self.delegates.forEach { (delegate: PageViewDelegate) in
                delegate.pageView(self, didEndDsiplayingPageAt: indexPath.item, cell: _cell)
            }
            _cell.didEndDisplaying(at: indexPath)
        }
    }

    //MARK: - UIScrollViewDelegate

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.enumerateScrollEventReceivers(closure: {$0.pageViewWillBeginDragging(self)})
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {return}
        let currentVisiblePages = self.calculateVisiblePages()
        //PVLog.verbose("发生滚动: \(currentVisiblePages)")
        self.checkPrefetch()
        //发送滚动事件
        if !self.jumping {
            //如果依然处于jumping模式, 则无需通知接收器,scrollTo的时候已经通知了
            let event = ScrollEvent.init(scrollDirection: self.scrollDirection, jump: false, animated: false, contentOffset: scrollView.contentOffset, visiblePages: currentVisiblePages, lastVisiblePages: self.lastVisiblePages)
            self.enumerateScrollEventReceivers(closure: {$0.pageView(self, didScrollWith: event)})
        }

        self.lastVisiblePages = currentVisiblePages
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.enumerateScrollEventReceivers(closure: {$0.pageViewDidEndDragging(self, willDecelerate: decelerate)})
        if !decelerate {
            self.scrollViewDidEndScrolling(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrolling(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrolling(scrollView)
    }

    open func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        self.jumping = false
        self.isUserInteractionEnabled = true
        self.wormholeJumpDataSource.removeAll()
        self.enumerateScrollEventReceivers(closure: {$0.pageViewDidEndScrolling(self)})
    }

}
