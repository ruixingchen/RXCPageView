//
//  ScrollEvent.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///一个滚动事件的抽象
public struct ScrollEvent {

    public var scrollDirection: UICollectionView.ScrollDirection
    ///这个滚动事件是跳转到另一个页面的, 比如用户手动指定跳转到某一页
    public var jump: Bool
    ///是否动画, 这个属性只有在jump的时候才有效,手动拖拽默认是false
    public var animated: Bool
    ///滚动发生时的offset, 如果是jump, 那么表示jump结束时的offset
    public let contentOffset: CGPoint
    ///滚动发生时的可见页面, 如果是jump, 表示jump结束时的可见页面
    public let visiblePages:[PageAttributes]
    public let lastVisiblePages:[PageAttributes]

}
