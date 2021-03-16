//
//  TitlePageTabBar+Enum.swift
//  Example
//
//  Created by ruixingchen on 2021/1/30.
//

import Foundation

public extension TitlePageTabBar {

    enum LayoutMode {
        ///自然排列, 不修改Cell的宽度
        case natural
        ///当宽度不足的时候, 拉伸所有Cell的宽度来填满可视宽度
        case expand
        ///忽略显示的内容,让所有Cell等宽
        case equal
    }

    /*
     private enum IndicatorBouncingStyle {
     ///指示器不进行bounce, 当pageView bounce的时候, 指示器不动
     case none
     ///平移, 指示器只移动, 不会缩放
     case translation
     ///缩放
     case scale
     ///视差效果, 一边平移一边缩放
     case parallax
     }
     */

}
