//
//  ImageLoadingState.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/19.
//

import Foundation

///图片的加载状态
public enum ImageLoadingState: Int, Comparable {

    public static func < (lhs: ImageLoadingState, rhs: ImageLoadingState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    //尚未开始加载
    case none = 0
    ///加载失败
    case failed
    ///正在查询缓存
    case querying
    //正在加载
    case downloading
    ///加载完成
    case loaded
}
