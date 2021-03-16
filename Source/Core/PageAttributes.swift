//
//  PageAttributes.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///表示一个页面View的各项属性
public struct PageAttributes {

    public var page: Int

    ///可见部分的rect
    public var visibleRect: CGRect
    public var invisibleRect: CGRect

    ///这一页的Frame
    public var frame: CGRect

    public func visibleSize(with scrollDirection: UICollectionView.ScrollDirection)-> CGFloat {
        switch scrollDirection {
        case .horizontal:
            return self.visibleRect.width
        case .vertical:
            return self.visibleRect.height
        @unknown default:
            return self.visibleRect.width
        }
    }

    public func invisibleSize(with scrollDirection: UICollectionView.ScrollDirection)-> CGFloat {
        switch scrollDirection {
        case .horizontal:
            return self.invisibleRect.width
        case .vertical:
            return self.invisibleRect.height
        @unknown default:
            return self.invisibleRect.width
        }
    }

}
