//
//  PageViewDataSource.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

public protocol PageViewDataSource: AnyObject {

    func numberOfPages(in pageView: PageView) -> Int

    func pageView(_ pageView: PageView, pageDataAt page: Int)->PageData

}
