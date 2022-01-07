//
//  TitlePageTabBar.swift
//  Example
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

open class TitlePageTabBar: UIView, PageTabBar, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PageViewScrollEventReceiver {

    open lazy var collectionView: UICollectionView = self.initCollectionView()
    open var backgroundView: UIView = UIView()
    open var hairlineView: UIView = UIView()
    open var indicatorView: UIView = UIView()

    open weak var delegate: TitlePageTabBarDelegate?

    ///默认内容的高度
    open var barHeight: CGFloat = 44
    ///backgroundView将填充顶部的空间
    open var fillTopArea: Bool = true

    open var indicatorHeight: CGFloat = 3
    ///如果设置了这个值, 那么指示器的宽度不会随着Cell尺寸变化
    open var indicatorFixedWidth:CGFloat?
    ///指示器偏移量
    open var indicatorLocationOffset: CGPoint?

    ///控制Cell的样式
    open var cellStyle: TitlePageTabBarCellStyle = TitlePageTabBarCellStyle.init()

    open var layoutMode: LayoutMode = .expand {
        didSet {
            if self.collectionView.bounds.width > 0 { self.reloadData() }
        }
    }

    open var items:[PageTabBarItem] {
        didSet {
            if self.collectionView.bounds.width > 0 { self.reloadData() }
        }
    }

    open var barTintColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }() {
        didSet {
            self.backgroundView.backgroundColor = self.barTintColor
        }
    }

    internal var cellSizes:[CGSize] = []
    private var lastCollectionViewFrame: CGRect = CGRect.zero
    internal var cellHighlightPercentages:[CGFloat] = []
    internal var lastScrollEvent: ScrollEvent?

    open func initCollectionView()->UICollectionView {
        let flow = UICollectionViewFlowLayout.init()
        flow.scrollDirection = .horizontal
        flow.sectionInset = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.estimatedItemSize = CGSize.zero
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flow)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TitlePageTabBarTextCell.self, forCellWithReuseIdentifier: "textCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        #if (debug || DEBUG)
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.showsVerticalScrollIndicator = true
        #endif
        return collectionView
    }

    public init(items:[PageTabBarItem], cellStyle: TitlePageTabBarCellStyle?) {
        self.items = items
        super.init(frame: CGRect.zero)
        if let _style = cellStyle {
            self.cellStyle = _style
        }
        self.initSetup()
    }

    public required init?(coder: NSCoder) {
        self.items = []
        super.init(coder: coder)
        self.initSetup()
    }

    open func initSetup() {
        self.backgroundView.backgroundColor = self.barTintColor
        self.addSubview(self.backgroundView)

        self.collectionView.backgroundColor = nil
        self.addSubview(self.collectionView)

        if #available(iOS 13, *) {
            self.hairlineView.backgroundColor = UIColor.separator
        } else {
            self.hairlineView.backgroundColor = UIColor.gray
        }
        self.addSubview(self.hairlineView)

        self.indicatorView.backgroundColor = UIColor.blue
        self.indicatorView.layer.cornerRadius = self.indicatorHeight/2
        self.collectionView.addSubview(self.indicatorView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutBackgroundView()
        self.layoutCollectionView()
        self.layoutHairline()
    }

    open func layoutBackgroundView() {
        let x = self.bounds.minX
        let y: CGFloat
        if self.fillTopArea {
            y = -self.frame.minY
        }else {
            y = self.bounds.minY
        }
        let width = self.bounds.width
        let height = self.bounds.maxY - y
        self.backgroundView.frame = CGRect.init(x: x, y: y, width: width, height: height)
    }

    open func layoutCollectionView() {
        let x = self.bounds.minX
        let y = self.bounds.maxY - self.barHeight
        let frame = CGRect.init(x: x, y: y, width: self.bounds.width, height: self.barHeight)
        if frame != self.lastCollectionViewFrame {
            self.lastCollectionViewFrame = frame
            self.reloadData()
            self.collectionView.frame = frame
        }
        if let event = self.lastScrollEvent {
            self.updateAppearance(event: event)
        }else {
            self.resetAppearance()
        }
    }

    open func layoutHairline() {
        let x = self.bounds.minX
        let width = self.bounds.width
        let height = 1/UIScreen.main.scale
        let y = self.bounds.maxY
        self.hairlineView.frame = CGRect.init(x: x, y: y, width: width, height: height)
    }

    public func barSize(thatFits size: CGSize) -> CGSize {
        return CGSize.init(width: size.width, height: self.barHeight)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize.init(width: size.width, height: self.barHeight)
    }

    ///重新计算数据, 并且重新加载数据
    open func reloadData() {
        self.cellSizes = self.calculateStretchedCellSize()
        self.collectionView.reloadData()
        self.collectionView.setNeedsLayout()
        self.collectionView.layoutIfNeeded()
    }

    ///更新当前的显示状态
    open func updateAppearance(event: ScrollEvent) {
        self.updateIndicatorViewLocation(event: event)
        self.updateCellHighlight(event: event)
        self.scrollToCenterIndicator(indicatorFrame: self.indicatorView.frame, animated: event.animated)
    }

    ///复位外观
    open func resetAppearance() {
        self.indicatorView.frame = self.calculateIndicatorFrame(leftPage: 0, rightPage: 0, percentage: 0)
        self.collectionView.setContentOffset(CGPoint.zero, animated: false)
        self.cellHighlightPercentages = self.items.map({_ in 0.0})
        if self.cellHighlightPercentages.isEmpty {
            self.cellHighlightPercentages[0] = 1
        }
        self.updateVisibleCellHighlight()
        self.collectionView.reloadData()
    }

    //MARK: - Calculator

    ///计算某个item的实际尺寸
    open func calculateItemSize(page: Int)->CGSize {
        let item = self.items[page]
        guard let title = item.title else {return CGSize.init(width: 24, height: self.barHeight)}
        let text = NSMutableAttributedString.init(string: title)
        text.addAttribute(.font, value: self.cellStyle.font, range: NSRange.init(location: 0, length: text.length))
        var size = text.size()
        size.width += 16
        size.height = self.barHeight - 0.1
        return size
    }

    ///计算所有Cell的尺寸(拉伸后的)
    open func calculateStretchedCellSize()->[CGSize] {
        let itemSizes = self.items.enumerated().map({self.calculateItemSize(page: $0.offset)})
        switch self.layoutMode {
        case .natural:
            return itemSizes
        case .equal:
            //所有Cell宽度都相等
            let contentWidth: CGFloat
            if let flow = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                contentWidth = self.bounds.width - flow.sectionInset.left - flow.sectionInset.right - flow.minimumLineSpacing*CGFloat(self.items.count-1)
            }else {
                contentWidth = self.bounds.width
            }
            let cellWidth = contentWidth/CGFloat(self.items.count)
            return self.items.map({ _ in
                return CGSize.init(width: cellWidth, height: self.barHeight)
            })
        case .expand:
            //拉伸Cell的宽度
            let contentWidth: CGFloat
            if let flow = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                contentWidth = self.bounds.width - flow.sectionInset.left - flow.sectionInset.right - flow.minimumLineSpacing*CGFloat(self.items.count-1)
            }else {
                contentWidth = self.bounds.width
            }
            let allItemWidth = itemSizes.reduce(0, {$0+$1.width})
            if allItemWidth >= contentWidth {return itemSizes}
            //拉伸每个Cell的宽度
            let widthOffset = (contentWidth - allItemWidth)/CGFloat(self.items.count)
            return itemSizes.map({CGSize.init(width: $0.width+widthOffset, height: $0.height)})
        }
    }

    ///获取某一页的指示器的位置, 支持左右两侧的虚拟页
    open func indicatorFrame(at page: Int)->CGRect {
        //这里可以对虚拟页采用不同的计算方式来为指示器实现不同的效果, 比如bouncing的时候进行平移或者缩小
        let cellFrame: CGRect
        if page < 0 {
            //左侧的虚拟页
            //这里默认按照平移来计算
            guard let attributes = self.collectionView.layoutAttributesForItem(at: IndexPath.init(item: 0, section: 0)) else {return CGRect.zero}
            cellFrame = CGRect.init(x: attributes.frame.origin.x, y: attributes.frame.origin.y, width: 0, height: attributes.frame.height)
        }else if page >= self.items.count {
            ///右侧的虚拟页
            guard let attributes = self.collectionView.layoutAttributesForItem(at: IndexPath.init(item: self.items.count-1, section: 0)) else {return CGRect.zero}
            cellFrame = CGRect.init(x: attributes.frame.maxX, y: attributes.frame.origin.y, width: 0, height: attributes.frame.height)
        }else {
            guard let attributes = self.collectionView.layoutAttributesForItem(at: IndexPath.init(item: page, section: 0)) else {return CGRect.zero}
            cellFrame = attributes.frame
        }

        let midX = cellFrame.midX
        let width: CGFloat = self.indicatorFixedWidth ?? cellFrame.width
        let height = self.indicatorHeight
        let x = midX - width/2
        let y = self.collectionView.bounds.maxY - height
        var _frame = CGRect.init(x: x, y: y, width: width, height: height)
        if let offset = self.indicatorLocationOffset {
            _frame.origin.x += offset.x
            _frame.origin.y += offset.y
        }
        return _frame
    }

    ///计算一个滚动事件中所有Cell对应的高亮百分比
    ///所有的滚动都看成是手指左滑的滚动, 即offset增大的滚动
    open func calculateCellHighlightPercentage(event: ScrollEvent)->[CGFloat] {
        var percentages:[CGFloat] = self.items.map({_ in 0.0})
        if event.visiblePages.count == 1 {
            percentages[event.visiblePages[0].page] = 1.0
        }else if event.visiblePages.count == 2 {
            //两页可见
            let left = event.visiblePages.min(by: {$0.page < $1.page})!
            let right = event.visiblePages.max(by: {$0.page < $1.page})!
            let percentage: CGFloat
            switch event.scrollDirection {
            case .horizontal:
               percentage = right.visibleSize(with: event.scrollDirection) / right.frame.width
            case .vertical:
               percentage = right.visibleSize(with: event.scrollDirection) / right.frame.height
            @unknown default:
                percentage = right.visibleSize(with: event.scrollDirection) / right.frame.width
            }
            percentages[right.page] = percentage
            percentages[left.page] = 1-percentage
        }else {
            //如果有三页可见, 不好判断进度, 取消
        }
        return percentages
    }

    ///根据两个页码和进度计算指示器的frame
    open func calculateIndicatorFrame(leftPage: Int, rightPage: Int, percentage: CGFloat)->CGRect {
        let leftIndicatorFrame = self.indicatorFrame(at: leftPage)
        if leftPage == rightPage {return leftIndicatorFrame}
        let rightIndicatorFrame = self.indicatorFrame(at: rightPage)
        let width = leftIndicatorFrame.width + (rightIndicatorFrame.width-leftIndicatorFrame.width)*percentage
        let height = leftIndicatorFrame.height + (rightIndicatorFrame.height-leftIndicatorFrame.height)*percentage
        let x = leftIndicatorFrame.minX + (rightIndicatorFrame.minX-leftIndicatorFrame.minX)*percentage
        let y = leftIndicatorFrame.minY + (rightIndicatorFrame.minY-leftIndicatorFrame.minY)*percentage
        let frame = CGRect.init(x: x, y: y, width: width, height: height)
        return frame
    }

    //MARK: - Tool

    open func onScrollEvent(_ event: ScrollEvent) {
        self.updateAppearance(event: event)
        self.lastScrollEvent = event
    }

    ///更新可见的Cell的高亮状态
    open func updateVisibleCellHighlight() {
        for i in self.collectionView.indexPathsForVisibleItems {
            if let cell = self.collectionView.cellForItem(at: i) {
                (cell as? TitlePageTabBarCell)?.highlight(percentage: self.cellHighlightPercentages[i.item], with: self.items[i.item], style: self.cellStyle)
            }
        }
    }

    open func updateIndicatorViewLocation(event: ScrollEvent) {
        let indicatorFrame: CGRect
        if event.visiblePages.count == 1 {
            let visiblePage = event.visiblePages[0]
            if visiblePage.invisibleSize(with: event.scrollDirection) == 0 {
                //当前只显示了一页
                indicatorFrame = self.indicatorFrame(at: visiblePage.page)
            }else {
                //只有一页同时改页被遮住了一部分, 表示正在进行bouncing
                if visiblePage.page == 0 {
                    //在左侧进行bouncing
                    let progress = visiblePage.visibleSize(with: event.scrollDirection)/visiblePage.frame.width
                    indicatorFrame = self.calculateIndicatorFrame(leftPage: -1, rightPage: 0, percentage: progress)
                }else {
                    //右侧bouncing
                    let progress = visiblePage.invisibleSize(with: event.scrollDirection)/visiblePage.frame.width
                    indicatorFrame = self.calculateIndicatorFrame(leftPage: visiblePage.page, rightPage: visiblePage.page+1, percentage: progress)
                }
            }
        }else if event.visiblePages.count == 2 {
            //两页可见
            let left = event.visiblePages.min(by: {$0.page < $1.page})!
            let right = event.visiblePages.max(by: {$0.page < $1.page})!
            let progress = right.visibleSize(with: event.scrollDirection)/right.frame.width
            indicatorFrame = self.calculateIndicatorFrame(leftPage: left.page, rightPage: right.page, percentage: progress)
        }else {
            //如果有三页可见, 不好判断进度, 取消
            indicatorFrame = self.indicatorView.frame
        }
        if event.animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.indicatorView.frame = indicatorFrame
            } completion: { (_) in

            }

        }else {
            self.indicatorView.frame = indicatorFrame
        }
    }

    open func updateCellHighlight(event: ScrollEvent) {
        self.cellHighlightPercentages = self.calculateCellHighlightPercentage(event: event)
        PVLog.verbose("计算所有cell高亮状态: \(self.cellHighlightPercentages)")
        self.updateVisibleCellHighlight()
    }

    ///滚动到将指示器居中的位置
    open func scrollToCenterIndicator(indicatorFrame: CGRect, animated: Bool) {
        let minOffset:CGFloat = 0
        let maxOffset:CGFloat = self.collectionView.contentSize.width-self.collectionView.bounds.width
        var targetOffset = indicatorFrame.midX - self.collectionView.bounds.width/2
        targetOffset = max(minOffset, min(targetOffset, maxOffset))
        self.collectionView.setContentOffset(CGPoint.init(x: targetOffset, y: 0), animated: animated)
    }

    //MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath)
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //即将要显示的时候更新Cell的状态
        (cell as? TitlePageTabBarCell)?.highlight(percentage: self.cellHighlightPercentages[indexPath.item], with: self.items[indexPath.item], style: self.cellStyle)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        self.delegate?.titlePageTabBar(self, didSelectPagAt: indexPath.item)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSizes[indexPath.item]
    }

    //MARK: - PageViewScrollEventReceiver

    open func pageViewWillBeginDragging(_ pageView: PageView) {

    }

    open func pageView(_ pageView: PageView, didScrollWith event: ScrollEvent) {
        self.onScrollEvent(event)
    }

    open func pageViewDidEndDragging(_ pageView: PageView, willDecelerate decelerate: Bool) {

    }

    open func pageViewDidEndScrolling(_ pageView: PageView) {

    }

}
