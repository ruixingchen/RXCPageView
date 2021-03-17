//
//  ColorPageViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/19.
//

import UIKit
import RXCPageView

class ColorPageViewController: PageViewController {

    init() {
        var vcs:[UIViewController] = []
        for i in 0..<3 {
            let vc = ColorViewController.init(color: UIColor.random())
            vc.title = "\(i)"
            vcs.append(vc)
        }
        super.init(viewControllers: vcs, page: 2)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initPageTabBar() -> PageTabBar? {
        let bar = super.initPageTabBar()
        if let _bar = bar as? TitlePageTabBar {
            _bar.layoutMode = .expand
            if #available(iOS 13.0, *) {
                _bar.cellStyle.textColor = UIColor.systemPink
                _bar.cellStyle.highlightTextColor = UIColor.systemGreen
            }
        }
        return bar
    }

}
