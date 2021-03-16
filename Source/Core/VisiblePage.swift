//
//  VisiblePage.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///表示一个当前可见的页面的各项属性
public struct PageAttributes {

    var page: Int
    ///可见部分的尺寸
    var visibleSize: CGFloat
    ///不可见部分的尺寸
    var invisibleSize: CGFloat

    ///这一页的Frame
    var frame: CGRect

}
