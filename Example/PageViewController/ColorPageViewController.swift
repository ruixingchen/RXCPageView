//
//  ColorPageViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/19.
//

import UIKit

class ColorPageViewController: PageViewController {

    init() {
        var vcs:[UIViewController] = []
        for i in 0..<10 {
            let vc = ColorViewController.init(color: UIColor.random())
            vc.title = "\(i)"
            vcs.append(vc)
        }
        super.init(viewControllers: vcs, page: 3)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initPageTabBar() -> PageTabBar? {
        let bar = super.initPageTabBar()
        (bar as? TitlePageTabBar)?.layoutMode = .equal
        return bar
    }

}
