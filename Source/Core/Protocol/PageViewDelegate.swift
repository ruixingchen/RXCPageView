//
//  PageViewDelegate.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

///PageView的主要代理, 可以监听到PageView的页面切换事件
public protocol PageViewDelegate: AnyObject {

    //just dequeued a cell from reuse pool, delegate can config the cell
    func pageView(_ pageView: PageView, didDequeuePageAt page: Int, cell: PageViewCell)

    ///will display a well configed cell, this is the last step this delegate can modify the cell
    func pageView(_ pageView: PageView, willDisplayPageAt page: Int, cell: PageViewCell)

    ///called on collectionView didEndDisplaying
    func pageView(_ pageView: PageView, didEndDsiplayingPageAt page: Int, cell: PageViewCell)

    func pageViewDidReloadData(_ pageView: PageView)

}
