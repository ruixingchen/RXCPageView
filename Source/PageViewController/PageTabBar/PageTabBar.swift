//
//  PageTabBar.swift
//  Example
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

///这个协议定义了一个TabBar, 由于TabBar的行为并不固定, 这里抽象得就简单一些, 只抽象一个获取尺寸的方法
public protocol PageTabBar where Self: UIView {

    ///这个方法与sizeThatFits在逻辑上是不同的, 一般来说这个方法返回的是一个固定的尺寸
    func barSize(thatFits size: CGSize)->CGSize

}
