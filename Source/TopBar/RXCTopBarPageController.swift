//
// Created by ruixingchen on 2020/4/1.
// Copyright (c) 2020 ruixingchen. All rights reserved.
//

import UIKit

open class RXCTopBarPageController: UIViewController, TitleScrollTopBarDataSource, RXCPageViewDelegate, RXCPageViewDataSource {

    open lazy var pageTopBar: UIView? = self.initPageTopBar()
    open lazy var pageView: RXCPageView = self.initPageView()

    ///当前的ViewController, 默认没有didSet监听, 如果手动设置的话, 需要手动调用reloadData方法
    open var viewControllers: [UIViewController]
    open var page: Int

    open func initPageTopBar() -> UIView? {
        let style: TitleScrollTopBarStyle = TitleScrollTopBarStyle()
        let bar: TitleScrollTopBar = TitleScrollTopBar(style: style)
        bar.dataSource = self
        return bar
    }

    open func initPageView()->RXCPageView {
        let view: RXCPageView = RXCPageView(frame: CGRect.zero, page: self.page)
        view.dataSource = self
        return view
    }

    public init(viewControllers:[UIViewController], page:Int) {
        self.viewControllers = viewControllers
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        self.viewControllers = coder.value(forKey: "viewControllers") as? [UIViewController] ?? []
        self.page = coder.value(forKey: "page") as? Int ?? 0
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.pageView)
        self.pageView.addDelegate(self)
        if let bar: UIView = self.pageTopBar {
            self.view.addSubview(bar)
        }
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutPageTopBar()
        self.layoutPageView()
        if let bar: UIView = self.pageTopBar {
            self.view.bringSubviewToFront(bar)
        }
    }

    open func layoutPageView() {
        self.pageView.frame = self.view.bounds
    }

    open func layoutPageTopBar() {
        guard let bar: UIView = self.pageTopBar, bar.superview == self.view else {
            return
        }
        let size: CGSize = bar.sizeThatFits(self.view.bounds.size)
        let x: CGFloat = self.view.bounds.midX - size.width / 2
        let safeAreaTop: CGFloat = self.view.safeAreaInsets.top - self.additionalSafeAreaInsets.top
        let y: CGFloat = safeAreaTop
        bar.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        if self.additionalSafeAreaInsets.top != bar.frame.maxY - safeAreaTop {
            self.additionalSafeAreaInsets.top = bar.frame.height
        }
    }

    ///设置ViewController并且重新加载界面
    ///
    /// - Parameters:
    ///   - viewControllers: 要加载的ViewController
    ///   - page: 不为nil的话会设置page, 否则显示当前页
    ///   - animated: 只是留一个接口, 暂时默认不进行动画
    open func setViewControllers(_ viewControllers: [UIViewController], page: Int?, animated: Bool) {
        self.viewControllers = viewControllers
        if let page: Int = page {
            self.pageView.currentPage = page
        }else {
            if self.pageView.currentPage >= viewControllers.count {
                self.pageView.currentPage = viewControllers.count - 1
            }
        }
        self.pageView.reloadViews()
    }

    //MARK: - TitleScrollTopBarDataSource

    open func titleScrollTopBarNumberOfItems(_ topBar: TitleScrollTopBar) -> Int {
        self.viewControllers.count
    }

    open func titleScrollTopBar(_ topBar: TitleScrollTopBar, itemForPageAt page: Int) -> TopBarItem {
        let item = TopBarItem()
        item.title = self.viewControllers[page].title
        return item
    }

    open func titleScrollTopBar(_ topBar: TitleScrollTopBar, didTapItemAt page: Int) {
        //滚动到对应的界面
        self.pageView.scroll(to: page, animated: true, allowJump: true)
    }

    //MARK: - RXCPageViewDataSource

    public func pageView(numberOfPages pageView: RXCPageView) -> Int {
        self.viewControllers.count
    }

    public func pageView(_ pageView: RXCPageView, viewAt page: Int) -> UIView {
        let vc: UIViewController = self.viewControllers[page]
        if vc.parent == nil {
            self.addChild(vc)
            vc.didMove(toParent: self)
        }
        return self.viewControllers[page].view
    }

    //MARK: - RXCPageViewDelegate

    open func pageView(willBeginJumping pageView: RXCPageView) {
        (self.pageTopBar as? RXCPageViewDelegate)?.pageView(willBeginJumping: pageView)
        self.view.isUserInteractionEnabled = false
    }

    open func pageView(didEndJumping pageView: RXCPageView) {
        (self.pageTopBar as? RXCPageViewDelegate)?.pageView(didEndJumping: pageView)
        self.view.isUserInteractionEnabled = true
    }

    open func pageView(_ pageView: RXCPageView, didShowViewAt page: Int) {
        (self.pageTopBar as? RXCPageViewDelegate)?.pageView(pageView, didShowViewAt: page)
        self.viewControllers[page].beginAppearanceTransition(true, animated: false)
        self.viewControllers[page].endAppearanceTransition()
    }

    open func pageView(_ pageView: RXCPageView, didHideViewAt page: Int) {
        (self.pageTopBar as? RXCPageViewDelegate)?.pageView(pageView, didHideViewAt: page)
        self.viewControllers[page].beginAppearanceTransition(false, animated: false)
        self.viewControllers[page].endAppearanceTransition()
    }

    open func pageView(_ pageView: RXCPageView, didScrollWith event: RXCPageView.ScrollEvent) {
        (self.pageTopBar as? RXCPageViewDelegate)?.pageView(pageView, didScrollWith: event)
    }
}
