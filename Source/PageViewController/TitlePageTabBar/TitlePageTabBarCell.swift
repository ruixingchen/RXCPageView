//
//  TitlePageTabBarCell.swift
//  Example
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

public protocol TitlePageTabBarCell where Self: UICollectionViewCell {

    ///返回某个item对应的Cell的尺寸
    //static func itemSize(with item: PageTabBarItem)->CGSize

    ///更新高亮状态
    func highlight(percentage: CGFloat, with item: PageTabBarItem, style: TitlePageTabBarCellStyle)

}
