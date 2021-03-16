//
//  PageViewScrollEventReceiver.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///PageView的滚动事件接收器, 可以接收到PageView的各种滚动事件和状态
public protocol PageViewScrollEventReceiver: AnyObject {

    func pageViewWillBeginDragging(_ pageView: PageView)

    func pageView(_ pageView: PageView, didScrollWith event: ScrollEvent)

    func pageViewDidEndDragging(_ pageView: PageView, willDecelerate decelerate: Bool)

    func pageViewDidEndScrolling(_ pageView: PageView)

}
