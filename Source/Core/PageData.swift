//
//  PageData.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import Foundation

///用一个协议抽象一个页面的数据
public protocol PageData {

    ///返回这个PageData对应的Cell的reuseIdentufier
    var cellIdentifier: String {get}

}
