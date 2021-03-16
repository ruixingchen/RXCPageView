//
//  PageViewPrefetchDelegate.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import Foundation

public protocol PageViewDataSourcePrefetching: AnyObject {

    ///要求进行预加载, 这个方法会随着滑动重复调用, 代理需要做好重复预加载的处理
    func pageView(_ pageView: PageView, prefetchPagesAt pages:[Int])

}
