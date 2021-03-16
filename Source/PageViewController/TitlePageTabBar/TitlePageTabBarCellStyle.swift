//
//  TitlePageTabBarCellStyle.swift
//  Example
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

///这里采用class是为了未来继承方便, 这个类只包含了一些基础属性, 实际使用可以继承后添加更多属性
open class TitlePageTabBarCellStyle {

    open var font: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    open var textColor: UIColor = UIColor.black
    open var highlightTextColor = UIColor.blue
    //open var highlightFont: UIFont = UIFont.systemFont(ofSize: 17, weight: .bold)
    ///高亮的时候的字体放大倍率
    //open var highlightScale: CGFloat = 1.3

    public init() {

    }

}
