//
//  TitlePageTabBarDelegate.swift
//  Example
//
//  Created by ruixingchen on 2021/1/30.
//

import UIKit

public protocol TitlePageTabBarDelegate: AnyObject {

    func titlePageTabBar(_ bar: TitlePageTabBar, didSelectPagAt page: Int)

}
