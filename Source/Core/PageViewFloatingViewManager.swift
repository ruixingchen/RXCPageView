//
//  PageViewFloatingViewManager.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///这个协议定义了悬浮View管理器,可以再PageView上添加一些浮层View
public protocol PageViewFloatingViewManager {

    func addSubviews(to pageView: PageView)

    func layoutSubviews(in pageView: PageView)

}
